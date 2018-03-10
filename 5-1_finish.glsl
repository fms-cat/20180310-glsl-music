#define BPM 140.0

#define PI 3.141592654
#define TAU 6.283185307

// ------
// general functions

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
// primitive oscillators

float sine( float phase ) {
    return sin( TAU * phase );
}

float saw( float phase ) {
    return 2.0 * fract( phase ) - 1.0;
}

float square( float phase ) {
    return fract( phase ) < 0.5 ? -1.0 : 1.0;
}

// ------
// drums

float kick( float time ) {
    float amp = exp( -5.0 * time );
    float phase = 50.0 * time
                - 10.0 * exp( -70.0 * time );
    return amp * sine( phase );
}

vec2 hihat( float time ) {
    float amp = exp( -50.0 * time );
    return amp * noise( time * 100.0 ).xy;
}

// ------
// synths

vec2 bass( float note, float time ) {
    float freq = noteToFreq( note );
    return vec2( square( freq * time ) + sine( freq * time ) ) / 2.0;
}

vec2 pad( float note, float time ) {
    float freq = noteToFreq( note );
    float vib = 0.2 * sine( 3.0 * time );
    return vec2(
        saw( freq * 0.99 * time + vib ),
        saw( freq * 1.01 * time + vib )
    );
}

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
// main

vec2 mainSound( float time ) {
    float beat = timeToBeat( time );
    vec2 ret = vec2( 0.0 );
    
    // ---
    // kick
    
    float kickTime = beatToTime( mod( beat, 1.0 ) );
    ret += 0.8 * kick( kickTime );
        
    float sidechain = smoothstep( 0.0, 0.4, kickTime );
    
    // ---
    // hihat
    
    float hihatTime = beatToTime( mod( beat + 0.5, 1.0 ) );
    ret += 0.5 * hihat( hihatTime );
    
    // ---
    // bass
    
    float bassNote = chord( 0.0 ) - 24.0;
    ret += sidechain * 0.6 * bass( bassNote, time );
    
    // ---
    // chord
    
    ret += sidechain * 0.6 * vec2(
        pad( chord( 0.0 ), time )
      + pad( chord( 1.0 ), time )
      + pad( chord( 2.0 ), time )
      + pad( chord( 3.0 ), time )
    ) / 4.0;
    
    // ---
    // arp
    
    float arpTime = beatToTime( mod( beat, 0.25 ) );
    float arpSeed = floor( beat / 0.25 );
    vec4 arpDice = fract( noise( arpSeed ) * 100.0 );
    
    float arpNote = chord( floor( 4.0 * arpDice.x ) );
    arpNote += 12.0 * floor( 3.0 * arpDice.y );

    ret += sidechain * 0.5 * vec2( arp( arpNote, arpTime ) );
    
    // ---
    
    return clamp( ret, -1.0, 1.0 );
}