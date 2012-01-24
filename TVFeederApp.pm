package TVFeederApp;

use strict;
use Wx qw/:allclasses/;
use base qw/Wx::App/;

use Sub::Signatures;
use MainFrame;
use TVFeederLib;

sub OnInit($self) {
	Wx::InitAllImageHandlers();

    my $lib = TVFeederLib->new()->init();
	my $mainFrame = MainFrame->new(
      undef, undef, undef, undef, Wx::Size->new(100, 600), undef, undef, $lib
    );
#	my($self, $parent, $id, $title, $pos, $size, $style, $name, $tvfLib) = @_;

	$self->SetTopWindow($mainFrame);
	$mainFrame->Show(1);

	return 1;
}

1;