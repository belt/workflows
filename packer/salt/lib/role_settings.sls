#!pyobjects

import csv
import StringIO
import re
import logging as log

class RoleSettings(object):
  """Reads salt-roles to help select which states get enforced"""

  def __init__(self, options={}):
    self.options = options
    self.as_organizations = self.select_organizations_from_roles()
    self.as_stages = self.select_stages_from_roles()

  def grain_roles(self):
    import csv
    import StringIO
    return csv.reader(StringIO.StringIO(grains('roles')))

  def has_role(self, role):
    api_roles = []
    for row in self.grain_roles():
      for cell in row:
        if cell == role:
          api_roles.append(role)
          break
    return True if api_roles else False

  def select_stages_from_roles(self):
    import re
    found_roles = ['development']
    for row in self.grain_roles():
      regex = re.compile('\Aas-(.*)')
      found_roles = [match.group(1) for cell in row for match in [regex.search(cell)] if match]
    return found_roles

  def select_organizations_from_roles(self):
    import re
    found_roles = ['m']
    for row in self.grain_roles():
      regex = re.compile('\Aorg_as-(.*)')
      found_roles = [match.group(1) for cell in row for match in [regex.search(cell)] if match]
    return found_roles
