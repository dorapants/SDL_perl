use strict;
use warnings;
use Test::More;
use SDL;
use SDL::Surface;
use SDL::Rect;
use SDL::Image;
use SDLx::LayerManager;
use SDLx::Layer;
use SDLx::Surface;
use SDLx::Sprite;
use SDL::PixelFormat;
use SDL::Video;
use lib 't/lib';
use SDL::TestTool;
use Data::Dumper;

my $videodriver = $ENV{SDL_VIDEODRIVER};
$ENV{SDL_VIDEODRIVER} = 'dummy' unless $ENV{SDL_RELEASE_TESTING};

if ( !SDL::TestTool->init(SDL_INIT_VIDEO) ) {
	plan( skip_all => 'Failed to init video' );
}

my $display = SDL::Video::set_video_mode( 800, 600, 32, SDL_SWSURFACE );
my $surface = SDL::Image::load('test/data/picture.bmp');

############# SDLx::Layer ###########################################################

my $hash = { id => 7 };
my $layer  = SDLx::Layer->new( $surface, 20, 40, 0, 5, 100, 120, $hash );
my $layer2 = SDLx::Layer->new( $surface, 60, 60 );
my $layer3 = SDLx::Layer->new( $surface, 60, 60, { aa => 'bb', bb => 'cc' } );

isa_ok( $layer, 'SDLx::Layer', 'SDLx::Layer->new' );
is( $layer->x, 20,  'SDLx::Layer->x' );
is( $layer->y, 40,  'SDLx::Layer->y' );
is( $layer->w, 100, 'SDLx::Layer->w' );
is( $layer->h, 120, 'SDLx::Layer->h' );
isa_ok( $layer->surface, 'SDL::Surface', 'SDLx::Layer->surface' );
is( $layer->surface->w, 180, 'SDLx::Layer->surface->w' );
is( $layer->surface->h, 200, 'SDLx::Layer->surface->h' );
isa_ok( $layer->clip, 'SDL::Rect', 'SDLx::Layer->clip' );
is( $layer->clip->x, 0,   'SDLx::Layer->clip->x' );
is( $layer->clip->y, 5,   'SDLx::Layer->clip->y' );
is( $layer->clip->w, 100, 'SDLx::Layer->clip->w' );
is( $layer->clip->h, 120, 'SDLx::Layer->clip->h' );
isa_ok( $layer->pos, 'SDL::Rect', 'SDLx::Layer->pos' );
is( $layer->pos->x, 20,  'SDLx::Layer->pos->x' );
is( $layer->pos->y, 40,  'SDLx::Layer->pos->y' );
is( $layer->pos->w, 180, 'SDLx::Layer->pos->w' );
is( $layer->pos->h, 200, 'SDLx::Layer->pos->h' );
isa_ok( $layer->data, 'HASH', 'SDLx::Layer->data' );
is( $layer2->data,       undef, 'SDLx::Layer->data' );
is( $layer->data->{id},  7,     'SDLx::Layer->data->{}' );
is( $layer3->data->{bb}, 'cc',  'SDLx::Layer->data->{}' );


############ SDLx::LayerManager #####################################################

my $manager = SDLx::LayerManager->new();
isa_ok( $manager, 'SDLx::LayerManager', 'SDLx::LayerManager->new' );
is( $manager->length, 0, 'SDLx::LayerManager->length' );
$manager->add($layer);  pass('SDLx::LayerManager->add');
$manager->add($layer2); pass('SDLx::LayerManager->add');
$manager->add($layer3); pass('SDLx::LayerManager->add');
is( $manager->length, 3, 'SDLx::LayerManager->length' );
isa_ok( $manager->layer(0), 'SDLx::Layer', 'SDLx::LayerManager->layer' );
isa_ok( $manager->layer(1), 'SDLx::Layer', 'SDLx::LayerManager->layer' );
is( $manager->layer(3),    undef, 'SDLx::LayerManager->layer' );
is( $manager->layer(-3),   undef, 'SDLx::LayerManager->layer' );
is( $manager->layer(0)->h, 120,   'SDLx::LayerManager->layer->h' );
isa_ok( $manager->layer(0)->surface, 'SDL::Surface', 'SDLx::LayerManager->layer->surface' );
is( $manager->layer(0)->surface->w, 180, 'SDLx::LayerManager->layer->surface->w' );
is( $manager->layer_by_position( 10, 30 ), undef, 'SDLx::LayerManager->layer_by_position' );
isa_ok( $manager->layer_by_position( 30, 50 ), 'SDLx::Layer', 'SDLx::LayerManager->layer_by_position' );
is( $manager->layer_by_position( 30, 50 )->index,      0,    'SDLx::LayerManager->layer_by_position->index' );
is( $manager->layer_by_position( 60, 60 )->index,      2,    'SDLx::LayerManager->layer_by_position->index' );
is( $manager->layer_by_position( 60, 60 )->data->{aa}, 'bb', 'SDLx::LayerManager->layer_by_position->data->{}' );
$manager->blit($display); pass('SDLx::LayerManager->blit');
SDL::Video::update_rect( $display, 0, 0, 0, 0 );

sleep(2);

if ($videodriver) {
	$ENV{SDL_VIDEODRIVER} = $videodriver;
} else {
	delete $ENV{SDL_VIDEODRIVER};
}

pass 'Final SegFault test';

done_testing;
