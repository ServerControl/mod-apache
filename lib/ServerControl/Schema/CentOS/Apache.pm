#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=3 sw=3 tw=0:
# vim: set expandtab:

package ServerControl::Schema::CentOS::Apache;

use strict;
use warnings;

use ServerControl::Schema;
use base qw(ServerControl::Schema::Module);

__PACKAGE__->register(
   
      'httpd'           => '/usr/sbin/httpd',
      'modules'         => '/usr/lib64/httpd/modules',
      'magic'           => '/etc/httpd/conf/magic',
      'mime.types'      => '/etc/mime.types',

);

1;
