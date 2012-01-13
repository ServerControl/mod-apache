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
use ServerControl::Exception::SyntaxError;

use base qw(ServerControl::Module);

our $VERSION = '0.109';

use Data::Dumper;

__PACKAGE__->Parameter(
   help  => { isa => 'bool', call => sub { __PACKAGE__->help; } },
   check => { isa => 'bool', call => sub { __PACKAGE__->check; } },
);

sub help {
   my ($class) = @_;

   print __PACKAGE__ . " " . $ServerControl::Module::Apache::VERSION . "\n";

   printf "  %-20s%s\n", "--path=", "The path where the instance should be created";
   printf "  %-20s%s\n", "--user=", "Apache User";
   printf "  %-20s%s\n", "--group=", "Apache Group";
   printf "  %-20s%s\n", "--name=", "Instance Name";
   printf "  %-20s%s\n", "--template=", "Which template to use";
   printf "  %-20s%s\n", "--options=", "Additional options for httpd like '-e info -E error.log'\n";
   print "\n";
   printf "  %-20s%s\n", "--create", "Create the instance";
   printf "  %-20s%s\n", "--start", "Start the instance";
   printf "  %-20s%s\n", "--stop", "Stop the instance";

}

sub start {
   my ($class) = @_;

   my ($name, $path) = ($class->get_name, $class->get_path);

   unless($class->check()) {
      ServerControl->say("Error in configurationfile. Won't start.");
      die(ServerControl::Exception::SyntaxError->new(message => 'Syntax Error in Configuration File. Please Check.'));
   }

   my $exec_file   = ServerControl::FsLayout->get_file("Exec", "httpd");
   my $config_file = ServerControl::FsLayout->get_file("Configuration", "httpdconf");

   my $options     = _get_options();
   my $defines     = _get_defines();

   if($config_file) {
      spawn("$path/$exec_file -d $path -f $path/$config_file $defines $options -k start");
   }
   else {
      spawn("$path/$exec_file -d $path $defines $options -k start");
   }
}

sub stop {
   my ($class) = @_;

   my ($name, $path) = ($class->get_name, $class->get_path);

   unless($class->check()) {
      ServerControl->say("Error in configurationfile. Won't stop.");
      die(ServerControl::Exception::SyntaxError->new(message => 'Syntax Error in Configuration File. Please Check.'));
   }

   my $exec_file   = ServerControl::FsLayout->get_file("Exec", "httpd");
   my $config_file = ServerControl::FsLayout->get_file("Configuration", "httpdconf");

   my $options     = _get_options();
   my $defines     = _get_defines();

   spawn("$path/$exec_file -d $path -f $path/$config_file $defines $options -k stop");
}

sub restart {
   my ($class) = @_;

   my ($name, $path) = ($class->get_name, $class->get_path);

   unless($class->check()) {
      ServerControl->say("Error in configurationfile. Won't restart.");
      die(ServerControl::Exception::SyntaxError->new(message => 'Syntax Error in Configuration File. Please Check.'));
   }

   my $exec_file   = ServerControl::FsLayout->get_file("Exec", "httpd");
   my $config_file = ServerControl::FsLayout->get_file("Configuration", "httpdconf");

   my $options     = _get_options();
   my $defines     = _get_defines();


   spawn("$path/$exec_file -d $path -f $path/$config_file $defines $options -k restart");
}

sub reload {
   my ($class) = @_;

   my ($name, $path) = ($class->get_name, $class->get_path);

   unless($class->check()) {
      ServerControl->say("Error in configurationfile. Won't reload.");
      die(ServerControl::Exception::SyntaxError->new(message => 'Syntax Error in Configuration File. Please Check.'));
   }

   my $exec_file   = ServerControl::FsLayout->get_file("Exec", "httpd");
   my $config_file = ServerControl::FsLayout->get_file("Configuration", "httpdconf");

   my $options     = _get_options();
   my $defines     = _get_defines();

   spawn("$path/$exec_file -d $path -f $path/$config_file $defines $options -k graceful");
}

sub status {
   my ($class) = @_;

   my ($name, $path) = ($class->get_name, $class->get_path);
   my $run_file = ServerControl::FsLayout->get_directory("Runtime", "pid");

   if(-f $path . '/' . $run_file . '/httpd.pid') { return 1; }
}

sub check {
   my ($class) = @_;

   my ($name, $path) = ($class->get_name, $class->get_path);

   my $exec_file   = ServerControl::FsLayout->get_file("Exec", "httpd");
   my $config_file = ServerControl::FsLayout->get_file("Configuration", "httpdconf");

   my $options     = _get_options();
   my $defines     = _get_defines();

   spawn("$path/$exec_file -d $path -f $path/$config_file $defines $options -t");

   if($? == 0) {
      return 1;
   }

   return 0;
}

# extract all with-* parameters from instance.conf
sub _get_defines {
   my $defines = join " -D ",
                     map { uc($_) . (ServerControl::Args->get->{"with-$_"} eq "1"?"":"=".ServerControl::Args->get->{"with-$_"}) }
                        map { /with-(.*)/ }
                           grep { /^with-/ } %{ServerControl::Args->get};
  
   $defines = "-D $defines " if($defines);
   return $defines;
}

# get all options from instance.conf
sub _get_options {
   my $options     = ServerControl::Args->get->{"options"} || "";
   return $options;
}

1;
