package MojoX::Renderer::Xslate;

use strict;
use warnings;

use File::Spec ();
use Mojo::Base -base;
use Mojo::Loader;
use Text::Xslate ();

our $VERSION = '0.09';
$VERSION = eval $VERSION;

has 'xslate';

sub build {
    my $self = shift->SUPER::new(@_);
    $self->_init(@_);
    return sub { $self->_render(@_) };
}

sub _init {
    my ($self, %args) = @_;

    my $app = $args{mojo} || $args{app};
    my $cache_dir;
    my @path = $app->home->rel_dir('templates');

    if ($app) {
        $cache_dir = $app->home->rel_dir('tmp/compiled_templates');
        push @path, Mojo::Loader->new->data(
            $app->renderer->classes->[0],
        );
    }
    else {
        $cache_dir = File::Spec->tmpdir;
    }

    my %config = (
        cache_dir    => $cache_dir,
        path         => \@path,
        warn_handler => sub { },
        die_handler  => sub { },
        %{$args{template_options} || {}},
    );

    $self->xslate(Text::Xslate->new(\%config));

    return $self;
}

sub _render {
    my ($self, $renderer, $c, $output, $options) = @_;

    my $name = $c->stash->{'template_name'}
        || $renderer->template_name($options);
    my %params = (%{$c->stash}, c => $c);

    local $@;
    if (defined(my $inline = $options->{inline})) {
        $$output = $self->xslate->render_string($inline, \%params);
    }
    else {
        $$output = $self->xslate->render($name, \%params);
    }
    die $@ if $@;

    return 1;
}


1;

__END__

=head1 NAME

MojoX::Renderer::Xslate - Text::Xslate renderer for Mojo

=head1 SYNOPSIS

    sub startup {
        ....

        # Via mojolicious plugin
        $self->plugin('xslate_renderer');

        # or manually
        use MojoX::Renderer::Xslate;
        my $xslate = MojoX::Renderer::Xslate->build(
            mojo             => $self,
            template_options => { },
        );
        $self->renderer->add_handler(tx => $xslate);
    }

=head1 DESCRIPTION

The C<MojoX::Renderer::Xslate> module is called by C<MojoX::Renderer> for
any matching template.

=head1 METHODS

=head2 build

    $renderer = MojoX::Renderer::Xslate->build(...)

This method returns a handler for the Mojo renderer.

Supported parameters are:

=over

=item mojo

C<build> currently uses a C<mojo> parameter pointing to the base class
object (C<Mojo>).

=item template_options

A hash reference of options that are passed to Text::Xslate->new().

=back

=head1 SEE ALSO

L<Text::Xslate>, L<MojoX::Renderer>

=head1 REQUESTS AND BUGS

Please report any bugs or feature requests to
L<http://rt.cpan.org/Public/Bug/Report.html?Queue=MojoX-Renderer-Xslate>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc MojoX::Renderer::Xslate

You can also look for information at:

=over

=item * GitHub Source Repository

L<http://github.com/gray/mojox-renderer-xslate>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/MojoX-Renderer-Xslate>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/MojoX-Renderer-Xslate>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/Public/Dist/Display.html?Name=MojoX-Renderer-Xslate>

=item * Search CPAN

L<http://search.cpan.org/dist/MojoX-Renderer-Xslate/>

=back

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010-2013 gray <gray at cpan.org>, all rights reserved.

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=head1 AUTHOR

gray, <gray at cpan.org>

=cut
