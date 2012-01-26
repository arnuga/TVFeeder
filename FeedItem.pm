package FeedItem;
use strict;

use Sub::Signatures;

use Class::MethodMaker
    [ new    => [qw/-hash new_hash_init/ ],
      scalar => [qw/feed
                    show_name
                    season_number
                    episode_number
                    format
                    is_proper
                    is_repack
                    original_title/
                ]
    ];

sub parse_feed($self)
{
    my $string = $self->feed->title();
    $self->original_title($string);
    
    $string =~ /(.*)(\d{1,2})[x|e](\d{2}).*/i;
    my $show_name = $1;
    $self->season_number($2);
    $self->episode_number($3);

    if($show_name) {
        $show_name =~ s/s0\s*$//i; #remove s0 if it is still hanging around at the end
        $show_name =~ s/\./ /g;    # replace all periods with a space
        $self->show_name($show_name);
    }
    
    my $format = undef;
    if ($string =~ /(\d{3,4}[i|p])/i) {
        $self->format($1);
    }

    if ($string =~ /(proper)/i) {
        $self->is_proper(1);
    }
    
    if ($string =~ /(repack)/i) {
        $self->is_repack(1);
    }
}

1;
