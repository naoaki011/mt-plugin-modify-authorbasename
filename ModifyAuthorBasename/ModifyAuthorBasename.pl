package MT::Plugin::ModifyAuthorBasename;
use strict;
use base 'MT::Plugin';
use vars qw($VERSION);
$VERSION = '1.0';
use MT;

my $plugin = MT::Plugin::ModifyAuthorBasename->new({
    name => 'Modify AuthorBasename',
    description => "Make AuthorBasename from AuthorName instead of AuthorNickname.",
    version => $VERSION,
});
MT->add_plugin($plugin);

{
  local $SIG{__WARN__} = sub {};

  *MT::Util::make_unique_author_basename = \&make_unique_author_basename;

}

use MT::Util qw( dirify );

sub make_unique_author_basename {
    my ($author) = @_;
    my $name = MT::Util::dirify($author->name || '');
    if ( !$name || ( $name !~ /\w/ ) ) {
        $name = MT::Util::dirify($author->nickname || '');
        if ( !$name || ( $name !~ /\w/ ) ) {
            if ( $author->id ) {
                $name = "author" . $author->id;
            }
            else {
                require Digest::MD5;
                $name = "author" . substr(
                    Digest::MD5::md5_hex( Encode::encode_utf8( $author->name ) ),
                    0, 5
                );
            }
        }
    }

    my $limit = MT->instance->config('AuthorBasenameLimit');
    $limit = 15 if $limit < 15; $limit = 250 if $limit > 250;
    my $base = substr($name, 0, $limit);
    $base =~ s/_+$//;
    my $i = 1;
    my $base_copy = $base;

    my $author_class = ref $author;
    return MT::Util::_get_basename( $author_class, $base );
}

1;
