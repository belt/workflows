# frozen_string_literal: true
module Overcommit
  module Hook
    module PreCommit
      # Git pre-commit hook that catches common developer-lint
      class OvercommitLintBlacklist < Base
        # The two sections of regular expressions below ('forbidden' and 'warning')
        # will trigger a commit failure, *if* they are found on an added or edited
        # line.

        # 'Forbidden' regular expressions
        FORBIDDEN = [
          /<<<<<</, /======/, />>>>>>/,  # Git conflict markers
          /console\.(?:debug|log)/,      # JavaScript debug code that would break IE.
          /save_and_open_page/,          # Launchy debugging code
          /binding\.(?:remote_)?pry/,    # pry debugging code
          /logger\.debug/, /debugger/    # Ruby debugging code
        ].freeze

        # Warning signs before committing a private key
        PRIVATE_KEY = [/PRIVATE KEY/, /ssh-rsa/].freeze

        # Will force a rejection, but will 'label' them in the error message as
        # 'merely' warnings.
        WARNING = [/alert/, /logger\.debug/].freeze

        def initialize(config, context)
          @full_diffs = `git diff --cached --`.scan(/^\+\+\+ b\/(.+)\n@@.*\n([\s\S]*?)(?:^diff|\z)/)
          @current_addition = ''
          @error_lines = []
          @warning_lines = []
          @context = context
          super config, context
        end

        # Loop over ALL errors and warnings and return ALL problems.  Report on *all*
        # problems that exist in the commit before aborting, so that anyone calling
        # --no-verify has been informed of all problems first.

        def run
          @full_diffs.each do |file, diff|
            @current_addition = diff.split("\n").select {|line| line.start_with?('+')}.join("\n")
            find_forbidden file
            find_private file
            find_warning file
          end

          :pass
        end

        # Scan for 'forbidden' calls
        def find_forbidden(file)
          FORBIDDEN.each do |re|
            next unless @current_addition.match(re)
            @error_lines << 'Error: git pre-commit hook forbids committing lines with ' \
                 "#{Regexp.last_match(1) || $&} to #{file}\n--------------)"
          end
          msg = @error_lines.join("\n") + 'To commit anyway, use --no-verify'
          return :fail, msg if @error_lines.any?
        end

        # Scan for private key indicators
        def find_private(file)
          PRIVATE_KEY.each do |re|
            next unless @current_addition.match(re)
            @error_lines << 'Error: git pre-commit hook detected a probable private key commit: ' \
                 "#{Regexp.last_match(1) || $&} to #{file}\n--------------)"
          end
          msg = @error_lines.join("\n") + 'To commit anyway, use --no-verify'
          return :fail, msg if @error_lines.any?
        end

        # Scan for 'suspect' calls
        def find_warning(file)
          WARNING.each do |re|
            next unless @current_addition.match(re)
            msg = 'Warning: git pre-commit hook is suspicious of committing lines with ' \
                  "#{Regexp.last_match(1) || $&} to #{file}\n--------------)"
            @warning_lines << msg
          end
          msg = @warning_lines.join("\n")
          return :warn, msg if @warning_lines.any?
        end
      end
    end
  end
end
