use v5.36;
use utf8;

use Cpanel::JSON::XS;
use WebService::Slack::WebApi;
use Module::Find qw / usesub /;

use lib "/var/task/lib";

sub handle {
    my ($payload, $context) = @_;

    my $body = decode_json $payload->{body};

    return $body->{challenge} if $body->{type} eq "url_verification";
    return if $body->{type} ne "event_callback";
    return if $body->{event}->{type} ne "message";
    return if defined $body->{event}->{bot_id};

    map { $_->judge($body) && $_->run($body) } usesub('Command');
}

1;