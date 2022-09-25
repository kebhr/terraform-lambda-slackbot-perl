use v5.36;
use utf8;

use Cpanel::JSON::XS;
use WebService::Slack::WebApi;

sub handle {
    my ($payload, $context) = @_;

    my $body = decode_json $payload->{body};

    return $body->{challenge} if $body->{type} eq "url_verification";
    return if $body->{type} ne "event_callback";
    return if $body->{event}->{type} ne "message";
    return if defined $body->{event}->{bot_id};

    my $slack = WebService::Slack::WebApi->new( token => $ENV{slack_token} );

    my $msg = $slack->chat->post_message(
        channel => $body->{event}->{channel},
        text    => 'fuga',
    );
}

1;