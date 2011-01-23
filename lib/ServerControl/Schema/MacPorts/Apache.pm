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
   
      'httpd'           => '/opt/local/apache2/bin/httpd',
      'modules'         => '/opt/local/apache2/modules',
      'magic'           => '/opt/local/apache2/conf/magic',
      'mime.types'      => '/opt/local/apache2/conf/mime.types',

);

1;
