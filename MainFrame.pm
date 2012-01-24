package MainFrame;

use strict;
use Wx qw/:everything/;
use base qw/Wx::Frame/;

require MainFrameActions;
use TVFeederLib;

sub new {
	my($self, $parent, $id, $title, $pos, $size, $style, $name, $tvfLib) = @_;
	$parent = undef              unless defined $parent;
	$id     = -1                 unless defined $id;
	$title  = ""                 unless defined $title;
	$pos    = wxDefaultPosition  unless defined $pos;
	$size   = wxDefaultSize      unless defined $size;
	$name   = ""                 unless defined $name;
	$tvfLib = TVFeederLib->new->init unless defined $tvfLib;

	$style = wxDEFAULT_FRAME_STYLE 
		unless defined $style;

	my @feed_names = $tvfLib->get_feedlist_names();
	
	$self = $self->SUPER::new( $parent, $id, $title, $pos, $size, $style, $name );
	$self->{lib} = $tvfLib;
	$self->{notebook_1} = Wx::Notebook->new($self, -1, wxDefaultPosition, wxDefaultSize, 0);
	$self->{notebook_1_pane_1} = Wx::Panel->new($self->Notebook, -1, wxDefaultPosition, wxDefaultSize, );
	$self->{window_1} = Wx::SplitterWindow->new($self->{notebook_1_pane_1}, -1, wxDefaultPosition, wxDefaultSize, wxSP_3D|wxSP_BORDER);
	$self->{window_1_pane_2} = Wx::Panel->new($self->{window_1}, -1, wxDefaultPosition, wxDefaultSize, );
	$self->{window_1_pane_1} = Wx::Panel->new($self->{window_1}, -1, wxDefaultPosition, wxDefaultSize, );
	$self->{combo_box_1} = Wx::ComboBox->new($self->{window_1_pane_1}, -1, "", wxDefaultPosition, wxDefaultSize, [ $self->{lib}->get_feedlist_names() ], wxCB_DROPDOWN|wxCB_READONLY);
	$self->FeedListComboBox->SetSelection(0);
	$self->FeedListComboBox->SetEditable(0);
	$self->{button_1} = Wx::Button->new($self->{window_1_pane_1}, -1, "Load Feed");
	$self->{grid_1} = Wx::Grid->new($self->{window_1_pane_2}, -1);
	$self->{notebook_1_pane_2} = Wx::Panel->new($self->Notebook, -1, wxDefaultPosition, wxDefaultSize, );

	$self->__set_properties();
	$self->__do_layout();

	Wx::Event::EVT_BUTTON($self, $self->{button_1}->GetId, \&btnLoadFeed);

	return $self;
}

sub __set_properties {
	my $self = shift;

	$self->SetTitle("TV Feeder");
	$self->FeedListComboBox->SetSelection(-1);
	$self->Grid->CreateGrid(0, 6);
	$self->Grid->EnableEditing(0);
	$self->Grid->SetColLabelValue(0, "Show");
	$self->Grid->SetColLabelValue(1, "Season");
	$self->Grid->SetColLabelValue(2, "Episode");
	$self->Grid->SetColLabelValue(3, "Format");
	$self->Grid->SetColLabelValue(4, "Is Proper");
	$self->Grid->SetColLabelValue(5, "Original Title");
	
	$self->Grid->SetColFormatNumber(1);
	$self->Grid->SetColFormatNumber(2);
	$self->Grid->SetColFormatBool(4);
	
	my @feed_names = $self->{lib}->get_feedlist_names();
	if (scalar(@feed_names) > 0) {
		$self->FeedListComboBox->SetSelection(0);
		
	}
}

sub __do_layout {
	my $self = shift;

	$self->{sizer_2} = Wx::BoxSizer->new(wxHORIZONTAL);
	$self->{sizer_3} = Wx::BoxSizer->new(wxHORIZONTAL);
	$self->{sizer_4} = Wx::BoxSizer->new(wxHORIZONTAL);
	$self->{sizer_6} = Wx::BoxSizer->new(wxVERTICAL);
	$self->{sizer_7} = Wx::BoxSizer->new(wxHORIZONTAL);
	$self->{sizer_7}->Add($self->FeedListComboBox, 0, 0, 0);
	$self->{sizer_7}->Add($self->{button_1}, 0, 0, 0);
	$self->{sizer_6}->Add($self->{sizer_7}, 1, wxEXPAND, 0);
	$self->{window_1_pane_1}->SetSizer($self->{sizer_6});
	$self->{sizer_4}->Add($self->Grid, 1, wxEXPAND, 0);
	$self->{window_1_pane_2}->SetSizer($self->{sizer_4});
	$self->{window_1}->SplitHorizontally($self->{window_1_pane_1}, $self->{window_1_pane_2}, );
	$self->{sizer_3}->Add($self->{window_1}, 1, wxEXPAND, 0);
	$self->{notebook_1_pane_1}->SetSizer($self->{sizer_3});
	$self->Notebook->AddPage($self->{notebook_1_pane_1}, "Feeds");
	$self->Notebook->AddPage($self->{notebook_1_pane_2}, "Shows");
	$self->{sizer_2}->Add($self->Notebook, 1, wxEXPAND, 0);
	$self->SetSizer($self->{sizer_2});
	$self->{sizer_2}->Fit($self);
	$self->Layout();
}


sub _load_feed_into_grid
{
	my ($self, $index) = @_;
	if ($index > -1) {
		my $url = $self->{lib}->get_feedlist_value($index);
		$self->clear_grid();
		
		my $rownum = 0;
		foreach my $item ($self->{lib}->get_entries_for_url($url)) {
			my $feed_item = $self->{lib}->get_feed_item($item);
			$feed_item->parse_feed();
			if ($feed_item->show_name && $feed_item->season_number && $feed_item->episode_number) {
				$self->Grid->AppendRows(1);
				$self->Grid->SetCellValue($rownum, 0, $feed_item->show_name || '');
				$self->Grid->SetCellValue($rownum, 1, $feed_item->season_number || 0);
				$self->Grid->SetCellValue($rownum, 2, $feed_item->episode_number || 0);
				$self->Grid->SetCellValue($rownum, 3, $feed_item->format || '');
				$self->Grid->SetCellValue($rownum, 4, $feed_item->is_proper || 0);
				$self->Grid->SetCellValue($rownum, 5, $feed_item->original_title || '');
				$rownum++;
			}
		}
	}
}

sub clear_grid
{
	my $self = shift;
	if ($self->Grid) {
		my $num_grid_rows = $self->Grid->GetNumberRows();
		if ($num_grid_rows > 0) {
			$self->Grid->DeleteRows(0, $num_grid_rows);
		}
	}
}

sub Grid { return (shift)->{grid_1}; }
sub Notebook { return (shift)->{notebook_1}; }
sub FeedListComboBox { return (shift)->{combo_box_1}; }

1;
