#!perl

use strict;
use warnings;

use Test::Spec;
use Test::More;
use Test::File::Contents;
use Test::VCR::LWP qw(withVCR);
use LWP::UserAgent;
use Sub::Name;
use File::Spec;

describe "A test recorder" => sub {
	my $original_lwp_request = \&LWP::UserAgent::request;
	
	it "should be able to create an object" => sub {
		my $sut = Test::VCR::LWP->new;
		isa_ok($sut, "Test::VCR::LWP");
	};
	my $sut;
	before each => sub {
		unlink('test.tape');
		$sut = Test::VCR::LWP->new(tape => 'test.tape');
	};
	it "should create a tape" => sub {
		$sut->run(sub {});
		ok(-f "test.tape");
	};
	it "should call the passed sub" => sub {
		my $called = 0;
		$sut->run(sub {
			$called++;
		});
		
		ok($called);
	};
	it "should replace LWP::UserAgent::request() for the passed sub" => sub {
		$sut->run(sub {
			cmp_ok(
				*LWP::UserAgent::request{CODE},
				'!=',
				$original_lwp_request
			);
		});
	};
	it "should not replace LWP::UserAgent::request() globally" => sub {
		$sut->run(sub { });
		cmp_ok(
			*LWP::UserAgent::request{CODE},
			'==',
			$original_lwp_request
		);
	};
	describe "with a lwp request" => sub {
		my $ua;
		before each => sub {
			$ua = LWP::UserAgent->new;
		};
		it "should record something" => sub {
			$sut->run(sub {
				$ua->get('http://www.apple.com');		
			});
			file_contents_like('test.tape', qr/apple/i);
		};
		it "should record another thing" => sub {
			$sut->run(sub {
				$ua->get('http://search.cpan.org');		
			});
			file_contents_like('test.tape', qr/cpan/i);				
		};
		it "should record if an exception is thrown" => sub {
			eval {
				$sut->run(sub {
					$ua->get('http://search.cpan.org');
					die "Exception!\n";
				});
			};
			file_contents_like('test.tape', qr/cpan/i);
		};
		it "should rethrow exceptions" => sub {
			eval {
				$sut->run(sub {
					$ua->get('http://search.cpan.org');
					die "Exception!\n";
				});
			};
			my $e = $@;
			is($e, "Exception!\n");
		};
		it "should record multiple things" => sub {
			$sut->run(sub {
				$ua->get('http://www.apple.com');
				$ua->get('http://search.cpan.org');		
			});
			file_contents_like('test.tape', qr/apple/i);
			file_contents_like('test.tape', qr/cpan/i);				
		};
		it "should play a previously recorded thing" => sub {
			my $res;
			
			$sut->run(sub {
				$ua->get('http://www.apple.com');
			});
			
			$sut->run(sub {
				$ua->protocols_forbidden(['http']);
				$res = $ua->get('http://www.apple.com');
			});
			isa_ok($res, "HTTP::Response");
			like($res->content, qr/apple/i);
		};
		it "should play previously recorded thingS." => sub {
			my @res;
			$sut->run(sub {
				$ua->get('http://www.apple.com');
				$ua->get('http://search.cpan.org');
			});
			
			$sut->run(sub {
				$ua->protocols_forbidden(['http']);

				@res = (
					$ua->get('http://www.apple.com'),
					$ua->get('http://search.cpan.org'),
				);
			});
			
			isa_ok($res[0], "HTTP::Response");
			like($res[0]->content, qr/apple/i);
			isa_ok($res[1], "HTTP::Response");
			like($res[1]->content, qr/cpan/i);
		};
		it "should play and then record when asked for something that isn't in the tape" => sub {
			my $res;
			
			$sut->run(sub {
				$ua->get('http://www.apple.com');
			});
			
			$sut->run(sub {
				$res = $ua->get('http://search.cpan.org');
			});
			isa_ok($res, "HTTP::Response");
			like($res->content, qr/cpan/i);
			
		};
		it "should know its recording state" => sub {
			$sut->run(sub {
				$ua->get('http://www.apple.com');
				ok($_->is_recording);
			});
			$sut->run(sub {
				$ua->get('http://www.apple.com');
				ok(!$_->is_recording);
			});
		};
	};
	describe "with a withVCR decorator" => sub {
		it "should run code that it is given" => sub {
			my $vcr_run = 0;
			withVCR {
				$vcr_run = 1;
			} tape => 'foo.tape';
			ok($vcr_run);
		};
		it "should run code using VCR" => sub {
			my $vcr_run = 0;
			no warnings 'redefine';
			local *Test::VCR::LWP::run = sub {
				$vcr_run = 1;
			};
			withVCR { } tape => 'foo.tape';
			
			ok($vcr_run);
		};
		it "should configure VCR via its args" => sub {
			my $orig = \&Test::VCR::LWP::new;
			my %sent_args;
			no warnings 'redefine';
			local *Test::VCR::LWP::new = sub {
				my ($class, %args) = @_;
				%sent_args = %args;
				return $orig->($class, %args);
			};
			withVCR { } tape => 'foo.tape';
			cmp_deeply(
				\%sent_args,
				{ tape => 'foo.tape'},
			);
		};
		it "should default the tapename to the calling sub name" => sub {
			my $orig = \&Test::VCR::LWP::new;
			my %sent_args;
			no warnings 'redefine';
			local *Test::VCR::LWP::new = sub {
				my ($class, %args) = @_;
				%sent_args = %args;
				return $orig->($class, %args);
			};
			my $caller = subname(foo => sub {
				withVCR { };
			});
			
			$caller->();
			
			my $file = File::Spec->catfile('t', 'foo.tape');
			cmp_deeply(
				\%sent_args,
				{ tape => re(qr:\Q$file\E$:) },
			);
			
			unlink($sent_args{tape});
		};
	};
};


END { unlink 'foo.tape' }

runtests unless caller;
