#define PI 3.141592654
#define TAU 6.283185307

// ------

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

float saw( float phase ) {
    return 2.0 * fract( phase ) - 1.0;
}

// ------

vec2 mainSound( float time ) {
    return vec2(
        saw( time * noteToFreq( chord( 0.0 ) ) )
      + saw( time * noteToFreq( chord( 1.0 ) ) )
      + saw( time * noteToFreq( chord( 2.0 ) ) )
      + saw( time * noteToFreq( chord( 3.0 ) ) )
    ) / 4.0;
}