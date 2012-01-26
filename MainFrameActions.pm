use strict;

sub btnAddFeed
{
    my ($self, $event) = @_;
    my $url_str = $self->{text_ctrl_2}->GetValue();
    warn "Got a request to add a link: $url_str";
    if (length($url_str) > 0 && $url_str =~ /^http/i) {
        my $new_name = substr($url_str, 0, 15);
        warn "New Name: $new_name";
        $self->{lib}->add_feed_entry($new_name, $url_str);
        $self->{lib}->save_feedlist();
        warn "Saved entry";
    } else {
        warn "Url [$url_str] length was " . length($url_str) . " Or the url didn't start with http";
    }
    $event->Skip;
}

sub btnLoadFeed
{
	my ($self, $event) = @_;
	my $index = $self->{choice_1}->GetCurrentSelection();
	$self->_load_feed_into_grid($index);
    $self->resize_grid();
	$event->Skip;
}

sub ResizeOccured
{
    my ($self, $event) = @_;
    $self->resize_grid();
    $event->Skip;
}

1;
