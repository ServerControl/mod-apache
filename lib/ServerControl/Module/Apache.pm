#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=3 sw=3 tw=0:
# vim: set expandtab:

package ServerControl::Module::Apache;

use ServerControl::Module;
use ServerControl::Commons::Process;

use base qw(ServerControl::Module);

our $VERSION = '0.90';

use Data::Dumper;

__PACKAGE__->Parameter(
   help  => { isa => 'bool', call => sub { __PACKAGE__->help; } },
);

__PACKAGE__->Directories(
   bin      => { chmod => 0755, user => 'root', group => 'root' },
   conf     => { chmod => 0700, user => 'root', group => 'root' },
   htdocs   => { chmod => 0755, user => ServerControl::Args->get->{'user'}, group => ServerControl::Args->get->{'group'} },
   error    => { chmod => 0755, user => ServerControl::Args->get->{'user'}, group => ServerControl::Args->get->{'group'} },
   logs     => { chmod => 0755, user => ServerControl::Args->get->{'user'}, group => ServerControl::Args->get->{'group'} },
   run      => { chmod => 0755, user => ServerControl::Args->get->{'user'}, group => ServerControl::Args->get->{'group'} },
   tmp      => { chmod => 0755, user => ServerControl::Args->get->{'user'}, group => ServerControl::Args->get->{'group'} },

   'conf/httpd-conf.d'     => { chmod => 0700, user => 'root', group => 'root' },
   'conf/vhost-conf.d'     => { chmod => 0700, user => 'root', group => 'root' },
);

__PACKAGE__->Files(
   'bin/httpd-' . __PACKAGE__->get_name  => { link => ServerControl::Schema->get('httpd') },

   'modules'                             => { link => ServerControl::Schema->get('modules') },

   'conf/magic'                          => { link => ServerControl::Schema->get('magic') },
   'conf/mime.types'                     => { link => ServerControl::Schema->get('mime.types') },
   'conf/httpd.conf'                     => { call => sub { ServerControl::Template->parse(@_); } },
);

sub help {
   print "apache-help\n";
}

sub start {
   my ($class) = @_;

   my ($name, $path) = ($class->get_name, $class->get_path);

   my $defines = join " -D ", map { uc } map { /with-(.*)/ } grep { /^with-/ } %{ServerControl::Args->get};
   $defines = "-D $defines " if($defines);

   spawn("$path/bin/httpd-$name -d $path -f $path/conf/httpd.conf $defines -k start");
}

sub stop {
   my ($class) = @_;

   my ($name, $path) = ($class->get_name, $class->get_path);
   spawn("$path/bin/httpd-$name -d $path -f $path/conf/httpd.conf -k stop");
}

sub restart {
   my ($class) = @_;

   my ($name, $path) = ($class->get_name, $class->get_path);
   spawn("$path/bin/httpd-$name -d $path -f $path/conf/httpd.conf -k restart");
}

sub reload {
   my ($class) = @_;

   my ($name, $path) = ($class->get_name, $class->get_path);
   spawn("$path/bin/httpd-$name -d $path -f $path/conf/httpd.conf -k graceful");
}

sub status {
   my ($class) = @_;

   my ($name, $path) = ($class->get_name, $class->get_path);
   if(-f $path . '/run/httpd.pid') { return 1; }
}



1;
