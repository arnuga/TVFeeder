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

	$self = $self->SUPER::new( $parent, $id, $title, $pos, $size, $style, $name );
	$self->{lib} = $tvfLib;
	
	$self->__setup_gui();
	$self->__set_properties();
	$self->__do_layout();
	$self->__setup_events();

	return $self;
}

sub __setup_gui {
	my $self = shift;

	$self->{notebook_1} = Wx::Notebook->new($self, -1, wxDefaultPosition, wxDefaultSize, 0);	
	$self->{notebook_1_pane_1} = Wx::Panel->new($self->{notebook_1}, -1, wxDefaultPosition, wxDefaultSize, );
	$self->{text_ctrl_1} = Wx::TextCtrl->new($self->{notebook_1_pane_1}, -1, "", wxDefaultPosition, wxDefaultSize, wxTE_PROCESS_ENTER|wxTE_PROCESS_TAB);
	$self->{text_ctrl_2} = Wx::TextCtrl->new($self->{notebook_1_pane_1}, -1, "", wxDefaultPosition, wxDefaultSize, wxTE_PROCESS_ENTER|wxTE_PROCESS_TAB);
	$self->{button_1} = Wx::Button->new($self->{notebook_1_pane_1}, wxID_ADD, "");
	$self->{label_1} = Wx::StaticText->new($self->{notebook_1_pane_1}, -1, "", wxDefaultPosition, wxDefaultSize);
	$self->{choice_1} = Wx::Choice->new($self->{notebook_1_pane_1}, -1, wxDefaultPosition, wxDefaultSize, [ $self->{lib}->get_feedlist_names() ]);
	$self->{button_2} = Wx::Button->new($self->{notebook_1_pane_1}, -1, "Load Feed");
	$self->{label_2} = Wx::StaticText->new($self->{notebook_1_pane_1}, -1, "", wxDefaultPosition, wxDefaultSize);
	$self->{grid_1} = Wx::Grid->new($self->{notebook_1_pane_1}, -1);
	$self->{notebook_1_pane_2} = Wx::Panel->new($self->{notebook_1}, -1, wxDefaultPosition, wxDefaultSize);
}

sub __setup_events {
	my $self = shift;

	Wx::Event::EVT_SIZE($self, \&ResizeOccured);	
	Wx::Event::EVT_BUTTON($self, $self->{button_1}->GetId, \&btnAddFeed);
	Wx::Event::EVT_BUTTON($self, $self->{button_2}->GetId, \&btnLoadFeed);
}

sub __set_properties {
	my $self = shift;

	$self->SetTitle("TV Feeder");
	$self->SetSize(Wx::Size->new(600, 300));
	$self->{text_ctrl_1}->SetMinSize(Wx::Size->new(200, 27));
	$self->{text_ctrl_2}->SetMinSize(Wx::Size->new(200, 27));
	$self->{choice_1}->SetMinSize(Wx::Size->new(200, 29));
	$self->{choice_1}->SetSelection(0);
	$self->{grid_1}->CreateGrid(0, 7);
	$self->{grid_1}->EnableEditing(0);
	$self->{grid_1}->EnableDragGridSize(0);
	$self->{grid_1}->SetSelectionMode(wxGridSelectRows);
	
	$self->{grid_1}->SetColLabelValue(0, "Show");
	$self->{grid_1}->AutoSizeColumn(0, 0);
	
	$self->{grid_1}->SetColLabelValue(1, "Season");
	$self->{grid_1}->SetColFormatNumber(1);
	$self->{grid_1}->AutoSizeColumn(1, 1);
	
	$self->{grid_1}->SetColLabelValue(2, "Episode");
	$self->{grid_1}->SetColFormatNumber(2);
	$self->{grid_1}->AutoSizeColumn(2, 1);
	
	$self->{grid_1}->SetColLabelValue(3, "Format");
	$self->{grid_1}->AutoSizeColumn(3, 1);
	
	$self->{grid_1}->SetColLabelValue(4, "Proper");
	$self->{grid_1}->SetColFormatBool(4);
	$self->{grid_1}->AutoSizeColumn(4, 1);
	
	$self->{grid_1}->SetColLabelValue(5, "RePack");
	$self->{grid_1}->SetColFormatBool(5);
	$self->{grid_1}->AutoSizeColumn(5, 1);
	
	$self->{grid_1}->SetColLabelValue(6, "Original Title");
	$self->{grid_1}->ForceRefresh();
	$self->{grid_1}->AutoSizeColumn(6, 0);
}

sub __do_layout {
	my $self = shift;
	
	$self->{sizer_1} = Wx::BoxSizer->new(wxVERTICAL);
	$self->{grid_sizer_1} = Wx::FlexGridSizer->new(2, 1, 10, 0);
	$self->{grid_sizer_2} = Wx::FlexGridSizer->new(2, 3, 0, 0);
	$self->{grid_sizer_2}->Add($self->{text_ctrl_2}, 0, 0, 0);
	$self->{grid_sizer_2}->Add($self->{button_1}, 0, 0, 0);
	$self->{grid_sizer_2}->Add($self->{label_1}, 0, 0, 0);
	$self->{grid_sizer_2}->Add($self->{choice_1}, 0, 0, 0);
	$self->{grid_sizer_2}->Add($self->{button_2}, 0, 0, 0);
	$self->{grid_sizer_2}->Add($self->{label_2}, 0, 0, 0);
	$self->{grid_sizer_2}->AddGrowableRow(1);
	$self->{grid_sizer_2}->AddGrowableCol(2);
	$self->{grid_sizer_1}->Add($self->{grid_sizer_2}, 1, wxEXPAND, 0);
	$self->{grid_sizer_1}->Add($self->{grid_1}, 1, wxEXPAND, 0);
	$self->{notebook_1_pane_1}->SetSizer($self->{grid_sizer_1});
	$self->{grid_sizer_1}->AddGrowableRow(1);
	$self->{grid_sizer_1}->AddGrowableCol(0);
	$self->{notebook_1}->AddPage($self->{notebook_1_pane_1}, "RSS Feeds");
	$self->{notebook_1}->AddPage($self->{notebook_1_pane_2}, "TV Shows");
	$self->{sizer_1}->Add($self->{notebook_1}, 1, wxEXPAND, 0);
	$self->SetSizer($self->{sizer_1});
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
				$self->{grid_1}->AppendRows(1);
				$self->{grid_1}->SetCellValue($rownum, 0, $feed_item->show_name || '');
				$self->{grid_1}->SetCellValue($rownum, 1, $feed_item->season_number || 0);
				$self->{grid_1}->SetCellValue($rownum, 2, $feed_item->episode_number || 0);
				$self->{grid_1}->SetCellValue($rownum, 3, $feed_item->format || '');
				$self->{grid_1}->SetCellValue($rownum, 4, $feed_item->is_proper || 0);
				$self->{grid_1}->SetCellValue($rownum, 5, $feed_item->is_repack || 0);
				$self->{grid_1}->SetCellValue($rownum, 6, $feed_item->original_title || '');
				$rownum++;
			}
		}
	}
}

sub clear_grid
{
	my $self = shift;
	if ($self->{grid_1}) {
		my $num_grid_rows = $self->{grid_1}->GetNumberRows();
		if ($num_grid_rows > 0) {
			$self->{grid_1}->DeleteRows(0, $num_grid_rows);
		}
	}
}

sub resize_grid
{
	my $self = shift;
    $self->{grid_1}->AutoSizeColumns(0);
    my $total_col_width = $self->{grid_1}->GetDefaultColSize();
    warn "Width of column -1 is: $total_col_width";
    $total_col_width += $self->{grid_1}->GetColSize(0);
    $total_col_width += $self->{grid_1}->GetColSize(1);
    $total_col_width += $self->{grid_1}->GetColSize(2);
    $total_col_width += $self->{grid_1}->GetColSize(3);
    $total_col_width += $self->{grid_1}->GetColSize(4);
    $total_col_width += $self->{grid_1}->GetColSize(5);
    
    my $window_width = $self->GetSize()->GetWidth();
    if ($total_col_width && $window_width && ($window_width > $total_col_width)) {
        my $new_col_6_width = $window_width - $total_col_width;
		$new_col_6_width = $new_col_6_width - 40;
        $self->{grid_1}->SetColSize(6, $new_col_6_width);
        warn "Window Width: $window_width | Col6 Width: $new_col_6_width";
    }
    $self->{grid_1}->ForceRefresh();
}

1;
