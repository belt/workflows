# This is a manifest file that'll be compiled into application.js, which will
# include all the files listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts,
# vendor/assets/javascripts, or vendor/assets/javascripts of plugins, if any,
# can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at
# the bottom of the compiled file.
#
# Read Sprockets README
# (https://github.com/sstephenson/sprockets#sprockets-directives) for details
# about supported directives.
#
#= require jquery
#= require jquery-ui
#= require jquery_ujs
#= require turbolinks
#= require tether
#= require bootstrap-sprockets
#= require_tree .
#= require bootstrap.min
$(document).ready ->
  $('.js-alert').fadeTo(2000, 500).slideUp 500, ->
    $('.alert-success').alert 'close'
    return

  $('[data-toggle="tooltip"]').tooltip()

  dt_picker_opts = 
    'autoSize': true
    'showButtonPanel': true
    'maxViewMode': 2
    'todayBtn': 'linked'
    'todayHighlight': true
    'autoclose': true
  $('.datepicker').datepicker dt_picker_opts

  return
