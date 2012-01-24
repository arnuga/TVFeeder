package TVFeederApp;

use strict;
use Wx qw/:allclasses/;
use base qw/Wx::App/;

use Sub::Signatures;
use TVFeederLib;
use MainFrame;
use TVFTaskBarIcon;

sub OnInit($self) {
	Wx::InitAllImageHandlers();

	my $lib = TVFeederLib->new()->init();
	my $size = Wx::Size->new(600, 600);
    
	my $mainFrame = MainFrame->new(
      undef, undef, undef, undef, $size, undef, undef, $lib
    );
#	my($self, $parent, $id, $title, $pos, $size, $style, $name, $tvfLib) = @_;

	$self->SetTopWindow($mainFrame);
	$mainFrame->Show(1);

	return 1;
}

1;