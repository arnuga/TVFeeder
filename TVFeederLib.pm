package TVFeederLib;
use strict;
use warnings;

use YAML::Syck;
$YAML::Syck::ImplicitTyping  = 1;
$YAML::Syck::ImplicitUnicode = 1;

use XML::FeedPP;
use Sub::Signatures;
use FeedItem;
use Class::MethodMaker
  [ new   => [ qw/new      / ],
    array => [ qw/feedlist/ ],
  ];

sub init($self)
{
  $self->_load_feedlist();
  return $self;
}

sub get_feedlist_names($self)
{
  return map { $_->{name} } $self->feedlist;
}

sub get_feedlist_values($self)
{
  return map { $_->{url} } $self->feedlist;
}

sub _load_feedlist($self)
{
  if (-f "feedlist.xml") {
    open(my $fh, "<:encoding(UTF-8)", "feedlist.xml");
    my @feedlist = LoadFile($fh);
    $self->feedlist(@feedlist);
    $fh->close;
  }
}

sub _save_feedlist($self)
{
#  @feedlist = (
#	{ name => 'Demonoid (1)', url => 'http://static.demonoid.me/rss/3.xml' },
#	{ name => 'Demonoid (2)', url => 'http://static.demonoid.me/rss/9.xml' },
#	{ name => 'btjunkie', url => 'http://btjunkie.org/rss.xml' },
#	{ name => 'isohunt', url => 'http://isohunt.com/js/rss/' },
#  );
  my @feedlist = $self->feedlist;
  open(my $fh, ">:encoding(UTF-8)", "feedlist.xml");
  DumpFile($fh, @feedlist);
  $fh->close;
}

sub get_feedlist_value($self, $index)
{
  if ($self->feedlist_count >= $index) {
    my $feed_item = $self->feedlist_index($index);
    return $feed_item->{url};
  }
  return undef;
}

sub get_entries_for_url($self, $url)
{
  my $feed_data = XML::FeedPP->new($url);
  return sort { $a->title() cmp $b->title() } $feed_data->get_item();
}

sub get_feed_item($self, $feed)
{
  return FeedItem->new_hash_init(feed => $feed);
}

sub feed_entry_parser($self, $feed_title)
{
  my $show_name      = undef;
  my $season_number  = undef;
  my $episode_number = undef;
  
  $feed_title =~ /(.*)(\d{1,2})[x|e](\d{2}).*/i;
  $show_name      = $1;
  $season_number  = $2;
  $episode_number = $3;

  my $format = undef;  
  if ($feed_title =~ /(\d{3,4}[i|p])/i) {
    $format = $1;
  }
  
  my $is_proper = 0;
  if ($feed_title =~ /(proper)/i) {
    $is_proper = $1 ? 1 : 0;
  }
  
  $show_name =~ s/s0\s*$//i;       #remove s0 if it is still hanging around at the end
  $show_name =~ s/\./ /g;        # replace all periods with a space
  
  return ($show_name, $season_number, $episode_number, $format, $is_proper, $feed_title);
}

1;
