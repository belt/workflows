#!pyobjects

import os
import logging as log

class RC_Paths(object):
  """looks up or guesses HOME"""

  def __init__(self, options={}):
    self.options = options
    self.as_account = options['account'] if 'account' in options else 'nobody'

  def home_account_path(self, account_name = None):
    account_name = account_name if account_name else self.as_account
    account = __salt__['user.info'](account_name)
    if account:
      return account['home']
    else:
      # make a copy
      short_account_name = (account_name + '.')[:-1].replace(r'.*\\','')
      short_account = __salt__['user.info'](short_account_name)
      if short_account:
        log.debug('salt found domain-account: %s' % account_name)
        return short_account['home']
      else:
        log.debug('salt did not find account: %s' % account_name)
        return os.path.expanduser('~%s' % account_name)
