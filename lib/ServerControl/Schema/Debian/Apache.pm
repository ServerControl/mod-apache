#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=3 sw=3 tw=0:
# vim: set expandtab:

package ServerControl::Schema::MacPorts::Apache;

use strict;
use warnings;

use ServerControl::Schema;
use base qw(ServerControl::Schema::Module);

__PACKAGE__->register(
   
      'httpd'           => '/usr/sbin/apache2',
      'modules'         => '/usr/lib/apache2/modules',
      'magic'           => '/etc/magic',
      'mime.types'      => '/etc/mime.types',

);

1;
