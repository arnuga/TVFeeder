use strict;

sub btnLoadFeed
{
	my ($self, $event) = @_;
	my $index = $self->FeedListComboBox->GetSelection();
	$self->_load_feed_into_grid($index);
	$event->Skip;
}

1;
