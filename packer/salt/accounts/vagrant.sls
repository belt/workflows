#!pyobjects

import pdb
import inspect
import logging as log

import random
import re
import os

class AccountResolver(object):
  """uses salt to resolve account info"""

  def __init__(self, options = {}):
    #super(object, self).__init__(options)

    # account name - on the assumption that domain accounts are
    #                backslash-delimited, support AD accounts
    # HACK: https://github.com/saltstack/salt/issues/12803
    account = options['account'] if 'account' in options else 'vagrant'
    if '\\' in account:
      domain, acct = account.split('\\')
      self.ad_domain = domain
      self.as_account = account
      self.smb_account = acct
      if True: # TODO: detect 'winbind use default domain = true' in samba
        self.fs_account = self.smb_account
      else:
        self.fs_account = self.as_account
    else:
      self.ad_domain = None
      self.as_account = account
      self.fs_account = self.as_account

    # primary group
    # ultimately this calls https://docs.python.org/2/library/pwd.html#pwd.getpwnam
    account_info = __salt__['user.info'](self.as_account)
    self.as_group = options['group'] if 'group' in options else 'vagrant'
    if account_info:
      self.account_exists = True
      self.as_gid = account_info['gid']
      self.as_group = __salt__['file.gid_to_group'](self.as_gid)

      # make assumptions based on OS
      if self.as_gid == self.as_group:
        if grains('kernel') == 'Linux':
          self.as_group = 'users'
        elif grains('kernel') == 'Darwin':
          self.as_group = 'staff'
        else:
          self.as_group = 'users'
    else:
      self.account_exists = False
      self.as_gid = __salt__['file.gid_to_group'](self.as_group)

    # UID / GID
    self.as_uid = __salt__['file.user_to_uid'](self.as_account)
    self.as_uid = None if not self.as_uid else self.as_uid

    # home path
    self.home_path = self.home_account_path(self.as_account)

    # password - defaults to randomly generated bits
    self.pw = pillar('passwords:system:%s' % self.as_account, '%012x' % random.randrange(16**128))

    self.enforce_ssh_id = False

  def home_account_path(self, account_name = None):
    account_name = account_name if account_name else self.as_account
    account = __salt__['user.info'](account_name)
    if account:
      return account['home']
    else:
      # make a copy
      short_account_name = (account_name + '.')[:-1].replace(r".*\\", "")
      short_account = __salt__['user.info'](short_account_name)
      if short_account:
        log.debug('salt found domain-account: %s' % account_name)
        return short_account['home']
      else:
        log.info('salt did not find account: %s' % account_name)
        return os.path.expanduser('~%s' % account_name)

class VagrantAccount(AccountResolver):
  """ensures vagrant ssh access"""

  def __init__(self, options = {}):
    super(VagrantAccount, self).__init__(options)

    self.host = grains('localhost', 'localhost')

  def ensure_account(self):
    User.present(self.as_account, shell='/bin/bash')

  # Can not create accounts in the Active Directory domain, so make a placeholder
  def state_requires(self):
    if self.ad_domain:
      return []
    else:
      return [User(self.as_account)]

  def enforce_ssh_path_bits(self):
    rc_paths = {('%s/.keychain' % self.home_path): 700, ('%s/.ssh' % self.home_path): 700}
    for path, mode in rc_paths.iteritems():
      File.directory("bits.%s" % path, name=path, mode=mode,
                     user=self.fs_account, group=self.as_group, makedirs=True,
                     recurse=['user', 'group'], require=self.state_requires())

  def enforce_authorized_keys_bits(self):
    authorized_keys_path = '%s/.ssh/authorized_keys' % self.home_path
    File.managed(('bits.%s' % authorized_keys_path), replace=False,
                 name=authorized_keys_path, creates=[authorized_keys_path], mode=600,
                 user=self.fs_account, group=self.as_group,
                 require=self.state_requires())

  def enforce_authorized_keys(self):
    authorized_keys_path = '%s/.ssh/authorized_keys' % self.home_path
    ssh_requires = self.state_requires() + [File('bits.%s' % authorized_keys_path)]
    has_the_bits = pillar('ssh:%s' % self.as_account, [self.as_account])
    for whom in has_the_bits:
      short_whom = re.sub(r'\A.*\\', "", whom)
      short_account = re.sub(r'\A.*\\', "", self.as_account)
      key_source = 'salt://keys/id_rsa.%s.workflows.pub' % whom
      key_source = re.sub(r'\\\\', r'\\', key_source)
      SshAuth.present(
        ('ssh.bits.authorized_keys.%s-%s' % (short_account, short_whom)),
        user=self.as_account, source=key_source,
        require=ssh_requires)

  def enforce_id_rsa(self):
    id_rsa_path = '%s/.ssh/id_rsa' % self.home_path
    File.managed(('secure.%s' % id_rsa_path), replace=False,
                 name=id_rsa_path, creates=[id_rsa_path], mode=400,
                 user=self.fs_account, group=self.as_group,
                 require=self.state_requires())

  def enforce_id_rsa_pub(self):
    id_rsa_pub_path = '%s/.ssh/id_rsa.pub' % self.home_path
    File.managed(('secure.%s' % id_rsa_pub_path), replace=False,
                 name=id_rsa_pub_path, creates=[id_rsa_pub_path], mode=400,
                 user=self.fs_account, group=self.as_group,
                 require=self.state_requires())


pkg = VagrantAccount()
pkg.ensure_account()
pkg.enforce_ssh_path_bits()
pkg.enforce_authorized_keys_bits()
pkg.enforce_authorized_keys()
if pkg.enforce_ssh_id:
  pkg.enforce_id_rsa()
  pkg.enforce_id_rsa_pub()
