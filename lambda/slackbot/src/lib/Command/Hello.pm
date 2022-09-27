package Command::Hello;

use v5.36;

sub judge {
    my ($class, $body) = @_;

    return $body->{event}->{text} eq "Hello";
}

sub run {
    my ($class, $body) = @_;

    my $slack = WebService::Slack::WebApi->new( token => $ENV{slack_token} );

    my $sender_name = do {
        my $sender = $slack->users->info(
            user => $body->{event}->{user},
        );
        $sender->{user}->{profile}->{display_name} || $sender->{user}->{profile}->{real_name};
    };

    my $msg = $slack->chat->post_message(
        channel => $body->{event}->{channel},
        text    => "Hello, " . $sender_name . "-san",
    );
}

1;