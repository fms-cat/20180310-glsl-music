#define BPM 140.0

#define PI 3.141592654
#define TAU 6.283185307

// ------

float timeToBeat( float t ) { return t / 60.0 * BPM; }
float beatToTime( float b ) { return b / BPM * 60.0; }

float noteToFreq( float n ) {
    return 440.0 * pow( 2.0, ( n - 69.0 ) / 12.0 );
}

float chord( float n ) {
    return (
        n < 1.0 ? 55.0 :
        n < 2.0 ? 58.0 :
        n < 3.0 ? 62.0 :
                  65.0
    );
}

vec4 noise( float phase ) {
    vec2 uv = phase / vec2( 0.512, 0.487 );
    return 2.0 * texture( iChannel0, uv ) - 1.0;
}

// ------

float sine( float phase ) {
    return sin( TAU * phase );
}

// ------

vec2 arp( float note, float time ) {
    float freq = noteToFreq( note );
    float fmamp = 0.1 * exp( -50.0 * time );
    float fm = fmamp * sine( time * freq * 7.0 );
    float amp = exp( -20.0 * time );
    return amp * vec2(
        sine( freq * 0.99 * time + fm ),
        sine( freq * 1.01 * time + fm )
    );
}

// ------

vec2 mainSound( float time ) {
    float beat = timeToBeat( time );
    
    float arpTime = beatToTime( mod( beat, 0.25 ) );
    float arpSeed = floor( beat / 0.25 );
    vec4 arpDice = fract( noise( arpSeed ) * 100.0 );
    
    float arpNote = chord( floor( 4.0 * arpDice.x ) );
    arpNote += 12.0 * floor( 3.0 * arpDice.y );

    return vec2( arp( arpNote, arpTime ) );
}