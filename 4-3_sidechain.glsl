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

// ------

float sine( float phase ) {
    return sin( TAU * phase );
}

float saw( float phase ) {
    return 2.0 * fract( phase ) - 1.0;
}

// ------

float kick( float time ) {
    float amp = exp( -5.0 * time );
    float phase = 50.0 * time
                - 10.0 * exp( -70.0 * time );
    return amp * sine( phase );
}

// ------

vec2 mainSound( float time ) {
    float beat = timeToBeat( time );
    float kickTime = beatToTime( mod( beat, 1.0 ) );
    float sidechain = smoothstep( 0.0, 0.4, kickTime );

    vec2 ret = vec2( kick( kickTime ) );
    ret += sidechain * (
      saw( time * noteToFreq( chord( 0.0 ) ) )
    + saw( time * noteToFreq( chord( 1.0 ) ) )
    + saw( time * noteToFreq( chord( 2.0 ) ) )
    + saw( time * noteToFreq( chord( 3.0 ) ) )
    ) / 4.0;
    return ret;
}