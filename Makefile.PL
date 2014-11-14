use ExtUtils::MakeMaker;

WriteMakefile(
	NAME         => 'Test::VCR::LWP',
	VERSION_FROM => 'lib/Test/VCR/LWP.pm', 
	AUTHOR       => 'Chris Reinhardt (crein@cpan.org)',
	ABSTRACT     => 'Record and playback LWP interactions.',
	PREREQ_PM    => {
		'LWP::UserAgent'       => 0,
	},
	TEST_REQUIRES => {
		'Test::More'           => 0,
		'Test::File::Contents' => 0,
		'Test::Spec'           => 0,
		'Test::Deep'           => 0,
		'Sub::Name'            => 0,
	},
	clean => { files => 't/*.tape *.tape' },
	LICENSE => 'perl',
	META_MERGE => {
		'meta-spec' => { version => 2 },
		contributors => [
			'Mark Ng <cpan@markng.co.uk>',
		],
		resources   => {
			homepage    => 'https://github.com/creinhardt/perl-Test-VCR-LWP',
			bugtracker  => {
				web    => 'https://github.com/creinhardt/perl-Test-VCR-LWP/issues',
			},
			repository  => {
				type => 'git',
				url  => 'https://github.com/creinhardt/perl-Test-VCR-LWP.git',
				web  => 'https://github.com/creinhardt/perl-Test-VCR-LWP',
			},
		},
	},
);

