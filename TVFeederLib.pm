package TVFeederLib;
use strict;
use warnings;

use IO::File;
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
    my $fh = new IO::File;
    open($fh, "<:encoding(UTF-8)", "feedlist.xml")
      or die "Unable to open feed file";
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
    my $feed_data;
  eval { $feed_data = XML::FeedPP->new($url); };
  if (my $err = $@) {
    warn "Failed to load feed";
    return ();
  } else {
    return sort { $a->title() cmp $b->title() } $feed_data->get_item();
  }
}

sub get_feed_item($self, $feed)
{
  return FeedItem->new_hash_init(feed => $feed);
}

1;
