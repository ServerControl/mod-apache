use ExtUtils::MakeMaker;

WriteMakefile(
   NAME => 'ServerControl-Apache',
   VERSION_FROM => 'lib/ServerControl/Module/Apache.pm',
   PREREQ_PM => {'ServerControl' => '0.90'},
   LICENSE => 'bsd'
);

