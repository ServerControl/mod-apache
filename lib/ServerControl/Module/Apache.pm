#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=3 sw=3 tw=0:
# vim: set expandtab:

package ServerControl::Module::Apache;

use strict;
use warnings;

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
   my ($class) = @_;

   print __PACKAGE__ . " " . $ServerControl::Module::Apache::VERSION . "\n";

   printf "  %-20s%s\n", "--path=", "The path where the instance should be created";
   printf "  %-20s%s\n", "--user=", "Apache User";
   printf "  %-20s%s\n", "--group=", "Apache Group";
   printf "  %-20s%s\n", "--name=", "Instance Name";
   printf "  %-20s%s\n", "--template=", "Which template to use";
   print "\n";
   printf "  %-20s%s\n", "--create", "Create the instance";
   printf "  %-20s%s\n", "--start", "Start the instance";
   printf "  %-20s%s\n", "--stop", "Stop the instance";

}

sub start {
   my ($class) = @_;

   my ($name, $path) = ($class->get_name, $class->get_path);

   my $defines = join " -D ", map { uc } map { /with-(.*)/ } grep { /^with-/ } %{ServerControl::Args->get};
   $defines = "-D $defines " if($defines);

   my $exec_file   = ServerControl::FsLayout->get_file("Exec", "httpd");
   my $config_file = ServerControl::FsLayout->get_file("Configuration", "httpdconf");

   spawn("$path/$exec_file -d $path -f $path/$config_file $defines -k start");
}

sub stop {
   my ($class) = @_;

   my ($name, $path) = ($class->get_name, $class->get_path);

   my $exec_file = ServerControl::FsLayout->get_file("Exec", "httpd");
   my $config_file = ServerControl::FsLayout->get_file("Configuration", "httpdconf");

   spawn("$path/$exec_file -d $path -f $path/$config_file -k stop");
}

sub restart {
   my ($class) = @_;

   my ($name, $path) = ($class->get_name, $class->get_path);

   my $exec_file = ServerControl::FsLayout->get_file("Exec", "httpd");
   my $config_file = ServerControl::FsLayout->get_file("Configuration", "httpdconf");

   spawn("$path/$exec_file -d $path -f $path/$config_file -k restart");
}

sub reload {
   my ($class) = @_;

   my ($name, $path) = ($class->get_name, $class->get_path);

   my $exec_file = ServerControl::FsLayout->get_file("Exec", "httpd");
   my $config_file = ServerControl::FsLayout->get_file("Configuration", "httpdconf");

   spawn("$path/$exec_file -d $path -f $path/$config_file -k graceful");
}

sub status {
   my ($class) = @_;

   my ($name, $path) = ($class->get_name, $class->get_path);
   my $run_file = ServerControl::FsLayout->get_directory("Runtime", "pid");

   if(-f $path . '/' . $run_file . '/httpd.pid') { return 1; }
}



1;
