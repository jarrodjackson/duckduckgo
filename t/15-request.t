#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use utf8::all;

use DDG::Request;

BEGIN {

	my @t = (
		'   !bang test'                   => {
			query_raw                 => '   !bang test',
			query                     => '!bang test',
			query_lc                  => '!bang test',
			query_nowhitespace        => '!bangtest',
			query_nowhitespace_nodash => '!bangtest',
			query_clean               => 'bang test',
			wordcount                 => 2,
			query_raw_parts           => ['','   ','!bang',' ','test'],
			query_parts               => [qw( !bang test )],
			words                     => [qw( bang test )],
			trigger                   => [
				[qw( !bang bang )],
				[qw()],
				[qw( test )],
			]
		},
		'!bang            test-test'      => {
			query_raw                 => '!bang            test-test',
			query                     => '!bang test-test',
			query_lc                  => '!bang test-test',
			query_nowhitespace        => '!bangtest-test',
			query_nowhitespace_nodash => '!bangtesttest',
			query_clean               => 'bang testtest',
			wordcount                 => 2,
			query_raw_parts           => ['!bang','            ','test-test'],
			query_parts               => [qw( !bang test-test )],
			words                     => [qw( bang test-test )],
			trigger                   => [
				[qw( !bang bang )],
				[qw()],
				[qw( test-test test testtest )],
			]
		},
		'other !bang test'                => {
			query_raw                 => 'other !bang test',
			query                     => 'other !bang test',
			query_lc                  => 'other !bang test',
			query_nowhitespace        => 'other!bangtest',
			query_nowhitespace_nodash => 'other!bangtest',
			query_clean               => 'other bang test',
			wordcount                 => 3,
			query_raw_parts           => ['other',' ','!bang',' ','test'],
			query_parts               => [qw( other !bang test )],
			words                     => [qw( other bang test )],
			trigger                   => [
				[qw( other )],
				[qw( !bang bang )],
				[qw( test )],
			]
		},
		'%"test %)()%!%§ +##+tesfsd' => {
			query_raw                         => '%"test %)()%!%§ +##+tesfsd',
			query                             => '%"test %)()%!%§ +##+tesfsd',
			query_lc                          => '%"test %)()%!%§ +##+tesfsd',
			query_nowhitespace                => '%"test%)()%!%§+##+tesfsd',
			query_nowhitespace_nodash         => '%"test%)()%!%§+##+tesfsd',
			query_clean                       => 'test tesfsd',
			wordcount                         => 2,
			query_parts                       => ['%"test',qq{%\)\(\)%!%§},'+##+tesfsd'],
			words                             => [qw( test tesfsd )],
			trigger                   => [
				['%"test'],
				['%)()%!%§'],
				['+##+tesfsd'],
			]
		},
		'test...test test...Test?'         => {
			query_raw                 => 'test...test test...Test?',
			query                     => 'test...test test...Test?',
			query_lc                  => 'test...test test...test?',
			query_nowhitespace        => 'test...testtest...Test?',
			query_nowhitespace_nodash => 'test...testtest...Test?',
			query_clean               => 'testtest testtest',
			wordcount                 => 2,
			query_parts               => [qw( test...test test...Test? )],
			words                     => [qw( test test test Test )],
		},
		'   %%test     %%%%%      %%%TeSFsd%%%  ' => {
			query_raw                         => '   %%test     %%%%%      %%%TeSFsd%%%  ',
			query                             => '%%test %%%%% %%%TeSFsd%%%',
			query_lc                          => '%%test %%%%% %%%tesfsd%%%',
			query_nowhitespace                => '%%test%%%%%%%%TeSFsd%%%',
			query_nowhitespace_nodash         => '%%test%%%%%%%%TeSFsd%%%',
			query_clean                       => 'test tesfsd',
			wordcount                         => 2,
			query_parts                       => [qw( %%test %%%%% %%%TeSFsd%%% )],
			words                             => [qw( test tesfsd )],
		},
		'reverse bla'                     => {
			query_raw                 => 'reverse bla',
			query                     => 'reverse bla',
			query_lc                  => 'reverse bla',
			query_nowhitespace        => 'reversebla',
			query_nowhitespace_nodash => 'reversebla',
			query_clean               => 'reverse bla',
			wordcount                 => 2,
			query_parts               => [qw( reverse bla )],
			words                     => [qw( reverse bla )],
		},
		'    !reverse bla   '             => {
			query_raw                 => '    !reverse bla   ',
			query                     => '!reverse bla',
			query_lc                  => '!reverse bla',
			query_nowhitespace        => '!reversebla',
			query_nowhitespace_nodash => '!reversebla',
			query_clean               => 'reverse bla',
			wordcount                 => 2,
			query_parts               => [qw( !reverse bla )],
			words                     => [qw( reverse bla )],
		},
		'    !REVerse BLA   '             => {
			query_raw                 => '    !REVerse BLA   ',
			query                     => '!REVerse BLA',
			query_lc                  => '!reverse bla',
			query_nowhitespace        => '!REVerseBLA',
			query_nowhitespace_nodash => '!REVerseBLA',
			query_clean               => 'reverse bla',
			wordcount                 => 2,
			query_parts               => [qw( !REVerse BLA )],
			words                     => [qw( reverse bla )],
		},
		'a really very very very very very long query 0123456789abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789' => {
			query_raw                 => 'a really very very very very very long query 0123456789abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789',
			query                     => 'a really very very very very very long query',
			query_lc                  => 'a really very very very very very long query',
			query_nowhitespace        => 'areallyveryveryveryveryverylongquery',
			query_nowhitespace_nodash => 'areallyveryveryveryveryverylongquery',
			query_clean               => 'a really very very very very very long query',
			wordcount                 => 9,
			query_raw_parts           => [ 'a', ' ', 'really', ' ', 'very', ' ', 'very', ' ', 'very', ' ', 'very', ' ', 'very', ' ', 'long',
				' ', 'query', ' ', '0123456789abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789' ],
			query_parts               => [qw( a really very very very very very long query )],
			words                     => [qw( a really very very very very very long query )],
			trigger                   => [
				['a'],
				['long','really','very'],
				['query'],
			]
		},
	);

	while (@t) {
		my $query = shift @t;
		my %result = %{shift @t};
		my %args;
		%args = $result{args} if defined $result{args};
		my $req = DDG::Request->new({ query_raw => $query, %args });
		isa_ok($req,'DDG::Request');
		is($req->query_raw,$query,'Testing query_raw of "'.$query.'"');
		for (qw/ query_raw query query_lc query_nowhitespace query_nowhitespace_nodash query_clean wordcount /) {
			is($req->$_,$result{$_},'Testing '.$_.' of "'.$query.'"') if defined $result{$_};
		}
		for (qw/ query_parts query_raw_parts /) {
			is_deeply($req->$_,$result{$_},'Testing '.$_.' of "'.$query.'"') if defined $result{$_};
		}
		for (qw/ combined_lc_words_2 /) {
			my $result_key = $_;
			my ( $param ) = $_ =~ m/_(\w)+$/;
			is_deeply($req->combined_lc_words($param),$result{$result_key},'Testing '.$result_key.' of "'.$query.'"') if defined $result{$result_key};
		}
		if (defined $result{trigger}) {
			for (0..2) {
				is_deeply([sort @{$req->trigger->[$_]}],[sort @{$result{trigger}->[$_]}],'Trigger test '.$_.' of "'.$query.'"');
			}
		}
	}
	
}

done_testing;
