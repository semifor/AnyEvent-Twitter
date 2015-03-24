use strict;
use Test::More;
use Test::Fatal;
use AnyEvent::Twitter;

{
    my $ua = AnyEvent::Twitter->new(
        consumer_key        => 'consumer_key',
        consumer_secret     => 'consumer_secret',
        access_token        => 'access_token',
        access_token_secret => 'access_token_secret',
    );

    # mock up a Twitter response
    local *AnyEvent::HTTP::http_request = sub {
        my $cb = pop;
        $cb->("{}", { Status => 200, Reason => 'OK' });
    };

    like(
        exception { $ua->get('account/verify_credentials', undef) },
        qr/callback coderef is required/,
        'dies with an undefined callback'
    );

    like(
        exception { $ua->get('account/verify_credentials', {}) },
        qr/callback coderef is required/,
        'dies with a non-CODE callback'
    );

    is(
        exception { $ua->get('account/verify_credentials', sub {}) },
        undef,
        'lives with a plain CODE callback'
    );

    is(
        exception { $ua->get('account/verify_credentials', bless sub {}, 'Foo') },
        undef,
        'lives with a blessed CODE callback'
    );

    is(
        exception {
            AnyEvent::Twitter->get_request_token(
                consumer_key    => 'consumer_key',
                consumer_secret => 'consumer_secret',
                callback_url    => 'oob',
                cb => bless sub {}, 'Foo'
            );
        }, undef, 'get_request_token accepts a blessed CODE ref'
    );

    is(
        exception {
            AnyEvent::Twitter->get_access_token(
                consumer_key       => 'consumer_key',
                consumer_secret    => 'consumer_secret',
                oauth_token        => 'token',
                oauth_token_secret => 'secret',
                oauth_verifier     => 'pin',
                cb => bless sub {}, 'Foo'
            );
        }, undef, 'get_access_token accepts a blessed CODE ref'
    );
}

done_testing;

