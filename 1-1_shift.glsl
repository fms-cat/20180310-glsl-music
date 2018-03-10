#define PI 3.141592654
#define TAU 6.283185307
#define BPM 175.0

#define V vec3(0.,1.,-1.)
#define saturate(i) clamp(i,0.,1.)
#define saturateA(i) clamp(i,-1.,1.)
#define lofi(i,j) floor((i)/j)*j
#define b2t(i) ((i)/BPM*60.0)
#define noten(i) 440.0*pow(2.0,(float(i)+trans)/12.0)

// ------

// general functions

vec4 random2D( vec2 _v ) {
  return fract( sin( texture( iChannel0, _v ) * 25711.34 ) * 175.23 );
}

vec4 random( float _v ) {
  return random2D( _v * V.yy );
}

// ------

// Instruments

// stronger kick
vec2 kick( float _phase ) {
  if ( _phase < 0.0 ) { return V.xx; }
  return V.yy * sin( _phase * 300.0 - exp( -_phase * 70.0 ) * 80.0 ) * exp( -_phase * 4.0 );
}

// weaker kick
vec2 kick2( float _phase ) {
  if ( _phase < 0.0 ) { return V.xx; }
  return V.yy * sin( _phase * 300.0 - exp( -_phase * 100.0 ) * 30.0 ) * exp( -_phase * 5.0 );
}

// stronger kick
vec2 snare( float _phase ) {
  if ( _phase < 0.0 ) { return V.xx; }
  return saturateA( (
    random( _phase / 0.034 ).xy +
    sin( _phase * 2500.0 * vec2( 1.005, 0.995 ) - exp( -_phase * 400.0 ) * 30.0 )
  ) * 2.0 * exp( -_phase * 23.0 ) );
}

// weaker kick
vec2 snare2( float _phase ) {
  if ( _phase < 0.0 ) { return V.xx; }
  return (
    random( lofi( _phase, 6E-5 ) / 2.06 ).xy * 0.5 +
    sin( _phase * 2000.0 * vec2( 1.005, 0.995 ) - exp( -_phase * 800.0 ) * 20.0 )
  ) * exp( -_phase * 31.0 );
}

// cowbell
vec2 cowbell( float _phase ) {
  if ( _phase < 0.0 ) { return V.xx; }
  vec2 cow = (
    sin( _phase * 800.0 * TAU * vec2( 1.005, 0.995 ) - exp( -_phase * 800.0 ) * 20.0 ) +
    sin( _phase * 540.0 * TAU * vec2( 0.995, 1.005 ) - exp( -_phase * 800.0 ) * 20.0 )
  );
  return sign( cow ) * pow( abs( cow ) * exp( -_phase * 20.0 ), 0.8 * V.yy );
}

// tom
vec2 tam( float _freq, float _phase ) {
  if ( _phase < 0.0 ) { return V.xx; }
  vec2 s = V.yy * 2.0 * sin( _phase * _freq * TAU + random( _phase * 1.45 ).xy * 0.1 - exp( -_phase * 1000.0 ) * 9.0 );
  float a = exp( -_phase * 20.0 ) / 2.5;
  return s * a;
}

// hihat
vec2 hihat( float _seed, float _dec ) {
  return random( _seed ).xy * exp( -_dec );
}

// main bass
float powNoise( float _freq, float _phase ) {
  if ( _phase < 0.0 ) { return 0.0; }
  float p = mod( _phase * _freq, 1.0 ) + random( _phase * 1.45 ).x * 0.01;
  return ( ( p < 0.4 ? -0.1 : 0.1 ) + sin( p * TAU ) * 0.7 );
}

// simple saw
float sharpSaw( float _phase ) {
  return mod( _phase, 1.0 ) * 2.0 - 1.0;
}

// pwm
float pwm( float _phase, float _pulse ) {
  return fract( _phase ) < _pulse ? -1.0 : 1.0;
}

// filtered saw, simulated by additive synthesis
float saw( float _freq, float _phase, float _filt, float _q ) {
  if ( _phase < 0.0 ) { return 0.0; }
  float sum = 0.0;
  for ( int i = 1; i <= 32; i ++ ) {
    float cut = smoothstep( _filt * 1.2, _filt * 0.8, float( i ) * _freq );
    cut += smoothstep( _filt * 0.3, 0.0, abs( _filt - float( i ) * _freq ) ) * _q;
    sum += sin( float( i ) * _freq * _phase * TAU ) / float( i ) * cut;
  }
  return sum;
}

// fm synthesis
vec2 fms( float _freq, float _phase, float _mod ) {
  if ( _phase < 0.0 ) { return V.xx; }
  float p = _phase * _freq * TAU;
  return vec2(
    sin( p * 0.999 + sin( p * _mod * 1.002 ) * exp( -_phase * 7.0 ) ),
    sin( p * 1.001 + sin( p * _mod * 0.998 ) * exp( -_phase * 7.0 ) )
  ) * exp( -_phase * 7.0 );
}

// DX7 tubular bell
vec2 bell( float _freq, float _phase ) {
  if ( _phase < 0.0 ) { return V.xx; }
  vec2 p = _freq * vec2( 1.001, 0.999 ) * _phase * TAU;
  float d = exp( -_phase * 1.0 );
  float d2 = exp( -_phase * 20.0 );
  return (
    sin( p * 1.0001 + sin( p * 3.5004 ) * d ) +
    sin( p * 0.9998 + sin( p * 3.4997 ) * d ) +
    sin( _phase * 2033.2 + sin( p * 1.9994 ) * exp( -_phase * 10.0 ) ) * exp( -_phase * 10.0 )
  ) * 0.3 * d;
}

// wtf is this
vec2 choir( float _freq, float _phase, float _time ) {
  if ( _phase < 0.0 ) { return V.xx; }
  vec2 sum = V.xx;
  for ( int i = 0; i < 6; i ++ ) {
    vec4 rand = random( float( i ) / 0.3 );
    vec2 p = ( _time - _phase ) + _phase * _freq * PI * ( 0.98 + 0.04 * rand.xy ) + float( i );
    p += sin( p / _freq * 3.0 + rand.zw );
    sum += sin( 2.0 * p + sin( p ) * 1.0 + sin( 7.0 * p ) * 0.02 );
  }
  return sum / 8.0;
}

// digital piano
vec2 cccp( float _freq, float _phase ) {
  if ( _phase < 0.0 ) { return V.xx; }
  vec2 p = _freq * vec2( 0.999, 1.001 ) * _phase * TAU;
  float dl = exp( -_phase * 1.0 );
  float ds = exp( -_phase * 10.0 );
  return (
    sin( p * 1.0003 + sin( p * 11.0035 ) * 1.5 * ds + sin( p * 1.0003 ) * 1.0 * dl ) +
    sin( p * 0.9997 + sin( p * 0.9997 + sin( p * 4.9984 ) * 2.0 * dl ) * 0.5 * ds )
  ) * 0.5 * ds;
}

// fm bass
vec2 bass( float _freq, float _phase ) {
  if ( _phase < 0.0 ) { return V.xx; }
  vec2 p = _freq * vec2( 0.999, 1.001 ) * _phase * TAU;
  float dl = exp( -_phase * 1.0 );
  float ds = exp( -_phase * 14.0 );
  return sin(
    p +
    sin( p ) * 1.5 * dl +
    sin( p + sin( p * 10.0 ) * 2.5 * ds ) * 3.0 * ds +
    sin( p + sin( p * 18.0 ) * 1.5 * ds ) * 0.5 * dl
  ) * 0.5 * dl;
}

// ------

vec2 mainSound( float time ) {
  float t = time;
  float beat = t * BPM / 60.0 - 8.0;
  vec2 ret = V.xx;
  float tenkai = floor( beat / 4.0 );
  float sidechain = 0.0;

  float trans = 3.0;

  float beati = floor( beat );
  float beatf = fract( beat );
  float beat32 = mod( beat, 32.0 );

  float kickTime;
  float snareTime;
  
  // ------

  // pi po po po
  if ( beat < 0.0 ) {
    ret += 0.5 * sin( TAU * t * ( mod( beat, 4.0 ) < 1.0 ? 2000.0 : 1000.0 ) ) * ( beatf < 0.1 ? 1.0 : 0.0 );
  }

  // ------

  // weaker kick'n'snare part
  if ( ( 0.0 < beat && beat < 64.0 ) || ( 192.0 < beat && beat < 256.0 ) ) {
    kickTime = b2t( mod( mod( beat, 4.0 ), 2.5 ) );
    snareTime = b2t( mod( beat - 1.0, 2.0 ) );
    float beat64 = mod( beat, 64.0 );

    ret += 0.7 * kick2( kickTime );
    ret += 0.5 * snare2( snareTime );
    sidechain = smoothstep( 0.0, 0.2, min( kickTime, snareTime ) );

    ret += 0.2 * sidechain * hihat( t, b2t( mod( beat, 0.5 ) ) * 100.0 );
    if ( 32.0 < beat ) {
      ret += 0.2 * hihat( t * 0.1, b2t( mod( beat, 0.25 ) ) * 1000.0 );
    }

    float build = max( 0.0, beat64 - 48.0 );
    float ksk = pow( build * 0.3, 2.0 );
    float vib = sin( t * ( 20.0 + ksk ) ) * ( 0.1 + ksk * 0.1 );
    ret += sidechain * sharpSaw( noten( -24 ) * t + vib ) * 0.04;
    ret += sidechain * sharpSaw( noten( -17 ) * t + vib ) * 0.04;
    ret += sidechain * sharpSaw( noten( -14 ) * t + vib ) * 0.04;
    ret += sidechain * sharpSaw( noten( -7 ) * t + vib ) * 0.04;
    ret += sidechain * sharpSaw( noten( 2 ) * t + vib ) * 0.04;

    ret += sidechain * 0.2 * build / 16.0 * random( lofi( t * 6.24, 0.0008 * lofi( build / 16.0, 0.02 ) ) ).xy;

    if ( 62.5 < beat64 ) {
      ret = 0.7 * kick( b2t( beat64 - 62.5 ) );
      ret += 0.5 * snare( b2t( beat64 - 63.0 ) );
      if ( 255.0 < beat ) {
        ret = 0.5 * snare( b2t( beat - 255.0 - lofi( beat - 255.0, 0.08 ) * 0.8 ) );
      }
    }
  }

  // ------

  // first half
  if ( 64.0 < beat && beat < 192.0 ) {
    if ( 124.5 < beat && beat < 128.0 ) {
      ret += 0.7 * kick2( b2t(
        mod( mod( beatf - 0.75, 1.0 ), 0.75 )
      ) );
      ret += 0.5 * snare2( b2t(
        mod( mod( beatf - 0.25, 1.0 ), 0.75 )
      ) );
      if ( 127.0 < beat ) {
        ret = 0.5 * snare( b2t( beat - 127.0 - lofi( beat - 127.0, 0.12 ) * 0.6 ) );
      }
      sidechain = 0.0;
    } else {
      kickTime = mod( beat, 4.0 ) < 2.5 ? b2t( mod( mod( beat, 4.0 ), 1.75 ) ) : b2t( mod( beat - 2.5, 4.0 ) );
      snareTime = b2t( mod( beat - 1.0, 2.0 ) );

      ret += 0.7 * kick( kickTime );
      ret += 0.5 * snare( snareTime );
      sidechain = smoothstep( 0.0, 0.2, min( kickTime, snareTime ) );
    }

    ret += 0.4 * tam( 300.0, b2t( mod( beat - 0.75, 2.0 ) ) );

    if ( 96.0 < beat ) {
      ret += 0.3 * sidechain * hihat( t, b2t( mod( beat, 0.25 ) ) * 100.0 );
    }

    if ( mod( beat, 2.0 ) < 1.0 ) {
      ret += sidechain * powNoise( noten( 0 ) / 8.0, t ) * 1.0;
    }
  }

  // second half
  if ( 256.0 < beat && beat < 448.0 ) {
    trans = beat < 320.0 ? 2.0 : beat < 384.0 ? 0.0 : -3.0;
    kickTime = mod( beat, 4.0 ) < 2.5 ? b2t( mod( mod( beat, 4.0 ), 1.75 ) ) : b2t( mod( beat - 2.5, 4.0 ) );
    snareTime = b2t( mod( beat - 1.0, 2.0 ) );

    if ( ( 316.0 < beat && beat < 320.0 ) || 444.0 < beat ) {
      sidechain = smoothstep( 0.0, 0.2, b2t( beatf ) );
    } else {
      ret += 0.7 * kick( kickTime );
      ret += 0.5 * snare( snareTime );
      sidechain = smoothstep( 0.0, 0.2, min( kickTime, snareTime ) );

      if ( beat < 384.0 ) {
        ret += 0.4 * tam( 300.0, b2t( mod( beat - 0.75, 2.0 ) ) );
        ret += 0.3 * sidechain * hihat( t, b2t( mod( beat, 0.25 ) ) * 100.0 );
      }

      float vib = sin( t * 20.0 ) * 0.1;
      ret += sidechain * sharpSaw( noten( -24 ) * t + vib ) * 0.04;
      ret += sidechain * sharpSaw( noten( -17 ) * t + vib ) * 0.04;
      ret += sidechain * sharpSaw( noten( -14 ) * t + vib ) * 0.04;
      ret += sidechain * sharpSaw( noten( -7 ) * t + vib ) * 0.04;
      ret += sidechain * sharpSaw( noten( 2 ) * t + vib ) * 0.04;
    }

    if ( mod( beat, 2.0 ) < 1.0 ) {
      ret += sidechain * powNoise( noten( 0 ) / 8.0, t ) * 1.0;
    }
  }

  // ------

  // soooo manyyy instrumentsss
  if ( ( 256.0 < beat && beat < 448.0 ) ) {
    if ( 1.25 < beat32 && beat32 < 2.0 ) {
      ret += saturateA( saw(
        noten( beatf < 0.5 ? 10 : beatf < 0.75 ? 12 : 0 ) / 4.0,
        b2t( mod( beat, 0.25 ) ),
        300.0 + 1200.0 * exp( -b2t( mod( beat, 0.25 ) ) * 20.0 ),
        7.0
      ) * 1.0 ) * 0.15;
    }

    if ( 3.0 < beat32 && beat32 < 4.0 )     {
      ret += bell( noten( -2 ), b2t( beatf - 0.75 ) ) * 0.2;
    }

    if ( 5.0 < beat32 && beat32 < 6.0 )     {
      ret += sidechain * sharpSaw( noten( 0 ) / 4.0 * t ) * 0.2;
    }

    if ( 7.0 < beat32 && beat32 < 8.0 ) {
      ret += sidechain * sharpSaw( noten( 0 ) * t + sin( t * 50.0 ) * 0.4 ) * 0.15;
    }

    if ( 9.0 < beat32 && beat32 < 10.0 ) {
      ret += 0.5 * tam( 200.0, b2t( beatf - 0.5 ) );
    }

    if ( 11.0 < beat32 && beat32 < 12.0 ) {
      if ( 0.5 < beatf ) {
        ret += saw(
          noten( beatf < 0.75 ? 10 : 0 ) / 4.0,
          b2t( mod( beatf, 0.25 ) ),
          300.0 + 4500.0 * exp( -b2t( mod( beatf, 0.25 ) ) * 20.0 ),
          3.0
        ) * 0.08;
      }
    }

    if ( 13.25 < beat32 && beat32 < 13.75 ) {
      float p = mod( noten( beatf < 0.5 ? -2 : 0 ) / 8.0 * b2t( beatf ), 1.0 );
      ret += 0.4 * exp( -1.0 * b2t( mod( beat, 0.25 ) ) ) * lofi( p < 0.5 ? p * 4.0 - 1.0 : 3.0 - p * 4.0, 0.1 );
    }
    
    if ( 15.0 < beat32 && beat32 < 16.0 ) {
      ret += fms( noten( 0 ) / 2.0, b2t( beatf - 0.5 ), 2.0 ) * 0.1;
      ret += fms( noten( 5 ) / 2.0, b2t( beatf - 0.5 ), 7.0 ) * 0.1;
      ret += fms( noten( 7 ) / 2.0, b2t( beatf - 0.5 ), 1.0 ) * 0.1;
      ret += fms( noten( 10 ) / 2.0, b2t( beatf - 0.5 ), 12.0 ) * 0.1;
    }

    if ( 17.0 < beat32 && beat32 < 18.0 ) {
      ret += 0.1 * sidechain * saw(
        noten( 0 ) / 8.0,
        lofi( b2t( beatf ), 2E-4 ),
        300.0 + 3500.0 * exp( -b2t( beatf ) * 10.0 ),
        7.0
      );
    }

    if ( 19.0 < beat32 && beat32 < 20.0 ) {
      ret += 0.2 * sidechain * pwm( t * noten( -38 ), 0.5 );
    }

    if ( 21.0 < beat32 && beat32 < 22.0 ) {
      ret += cccp( noten( 2 ), b2t( beatf - 0.25 ) ) * 0.1;
      ret += cccp( noten( 3 ), b2t( beatf - 0.5 ) ) * 0.1;
      ret += cccp( noten( 10 ), b2t( beatf - 0.75 ) ) * 0.1;
    }

    if ( 23.0 < beat32 && beat32 < 24.0 ) {
      ret += cowbell( b2t( beatf - 0.5 ) ) * 0.2;
    }

    if ( 25.25 < beat32 && beat32 < 25.75 ) {
      ret += 0.15 * bass( noten( beatf < 0.5 ? -26 : -24 ), b2t( mod( beatf, 0.25 ) ) );
    }

    if ( 27.00 < beat32 && beat32 < 28.00 ) {
      ret += 0.15 * bass( noten( -26 ), b2t( lofi( beatf, 0.001 ) - 0.5 ) * 0.5 );
    }

    if ( 29.0 < beat32 && beat32 < 30.0 ) {
      ret += 0.1 * sidechain * pwm( t * noten( -7 ), beatf * 0.5 );
    }

    if ( 31.0 < beat32 && beat32 < 32.0 ) {
      int n = int( mod( floor( beatf * 12.0 ), 6.0 ) );
      ret += 0.1 * sidechain * pwm( t * noten( n == 0 ? 0 : n == 1 ? 5 : n == 2 ? 7 : n == 3 ? 12 : n == 4 ? 17 : 19 ), 0.25 );
    }
  }

  // ------

  // arp for first half
  if ( 128.0 < beat && beat < 254.5 ) {
    for ( int i = 0; i < 3; i ++ ) {
      float dice = random( floor( ( beat - float( i ) * 0.75 ) / 0.25 ) / 4.72 ).x;
      int dicen = int( dice * 5.0 );
      float note = dicen == 0 ? 0.0 : dicen == 1 ? 7.0 : dicen == 2 ? 10.0 : dicen == 3 ? 17.0 : 26.0;
      float diceo = mod( floor( dice * 15.0 ), 3.0 );
      note += diceo * 12.0;
      ret += 0.07 / float( i * 4 + 1 ) * cccp( noten( note ) / 2.0, b2t( mod( beatf, 0.25 ) ) );
    }
  }

  // arp for second half
  if ( 320.0 < beat && beat < 444.0 ) {
    for ( int i = 0; i < 3; i ++ ) {
      float dice = random( floor( ( beat - float( i ) ) / 0.25 ) / 4.72 ).x;
      int dicen = int( dice * 5.0 );
      float note = dicen == 0 ? 0.0 : dicen == 1 ? 7.0 : dicen == 2 ? 10.0 : dicen == 3 ? 17.0 : 26.0;
      float diceo = mod( floor( dice * 15.0 ), 3.0 );
      note += diceo * 12.0;
      float ph = b2t( mod( beatf, 0.25 ) );
      ret += 0.03 * saw( noten( note ) / 2.0, ph, 200.0 + 6500.0 * exp( -ph * 20.0 ) / float( i * 5 + 1 ), 0.0 );
    }
  }

  // ------

  return saturateA( ret );
}