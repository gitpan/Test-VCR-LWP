use ExtUtils::MakeMaker;

my %MakeFile = (
	NAME         => 'Test::VCR::LWP',
	VERSION_FROM => 'lib/Test/VCR/LWP.pm', 
	AUTHOR       => 'Chris Reinhardt (crein@cpan.org)',
	ABSTRACT     => 'Record and playback LWP interactions.',
	clean => { files => 't/*.tape *.tape' },
	LICENSE => 'perl',
	META_MERGE => {
		'meta-spec' => { version => 2 },
		contributors => [
			'Mark Ng <cpan@markng.co.uk>',
		],
		resources   => {
			homepage    => 'https://github.com/ctriv/perl-Test-VCR-LWP',
			bugtracker  => {
				web    => 'https://github.com/ctriv/perl-Test-VCR-LWP/issues',
			},
			repository  => {
				type => 'git',
				url  => 'https://github.com/ctriv/perl-Test-VCR-LWP.git',
				web  => 'https://github.com/ctriv/perl-Test-VCR-LWP',
			},
		},
	},
);

my %test_depends = (
	'Test::More'           => 0,
	'Test::File::Contents' => 0,
	'Test::Spec'           => 0,
	'Test::Deep'           => 0,
	'Test::Exception'      => 0,
	'Sub::Name'            => 0,
);

my %depends = (
	'LWP::UserAgent'       => 0,
);

if (eval { ExtUtils::MakeMaker->VERSION(6.64) }) {
	$MakeFile{TEST_REQUIRES} = \%test_depends;
	$MakeFile{PREREQ_PM}     = \%depends;
} else {
	$MakeFile{PREREQ_PM} = {
		%test_depends,
		%depends
	};
}


WriteMakefile(%MakeFile);
	
