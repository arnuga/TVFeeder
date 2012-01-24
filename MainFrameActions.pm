use strict;

sub btnLoadFeed
{
	my ($self, $event) = @_;

	my $index = $self->{combo_box_1}->GetCurrentSelection;
	$self->_load_feed_into_grid($index);
	$event->Skip;
}

1;
