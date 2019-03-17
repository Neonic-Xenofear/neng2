module engine.core.math.color;

struct SColor4 {
	ubyte r;
	ubyte g;
	ubyte b;
	ubyte a;

	@nogc
	this( ubyte i_r, ubyte i_g, ubyte i_b, ubyte i_a = 255 ) pure nothrow {
		r = i_r;
		g = i_g;
		b = i_b;
		a = i_a;
	}

	@nogc
	this( uint i_hexCode ) pure nothrow {
		version( LittleEndian ) {
			a = ( i_hexCode >> 24 ) & 0xff;
			b = ( i_hexCode >> 16 ) & 0xff;
			g = ( i_hexCode >> 8  ) & 0xff;
			r = i_hexCode & 0xff;
		} else {
			r = ( i_hexCode >> 24 ) & 0xff;
			g = ( i_hexCode >> 16 ) & 0xff;
			b = ( i_hexCode >> 8  ) & 0xff;
			a = i_hexCode & 0xff;
		}
	}

	this( string code ) {
		import std.string : split, replace, isNumeric;
		import std.conv : to;

		string[] list = code.replace( " ", "" ).split( "," );
		if ( list.length > 3 ) {
			if ( list[0].isNumeric ) {
				r = cast( ubyte )( to!float( list[0] ) * 255 );
			} else {
				r = 0;
			}

			if ( list[1].isNumeric ) {
				g = cast( ubyte )( to!float( list[1] ) * 255 );
			} else {
				g = 0;
			}

			if ( list[2].isNumeric ) {
				b = cast( ubyte )( to!float( list[2] ) * 255 );
			} else {
				b = 0;
			}

			if ( list[3].isNumeric ) {
				a = cast( ubyte )( to!float( list[3] ) * 255 );
			} else {
				a = 255;
			}
		}
	}

	@nogc
	bool opEquals( ref const SColor4 i_opCol ) const pure nothrow {
		return  r == i_opCol.r && 
			g == i_opCol.g && 
			b == i_opCol.b && 
			a == i_opCol.a;
	}

	@nogc
	ubyte[4] getAsRGBA() const pure nothrow {
		return [r, g, b, a];
	}

	@nogc
	ubyte[3] getAsRGB() const pure nothrow {
		return [r, g, b];
	}

	float[] getAsRGBANormalized() {
		return[r / 255.0f, g / 255.0f, b / 255.0f, a / 255.0f];
	}

	static immutable SColor4 black = SColor4( 0, 0, 0, 255 );
    static immutable SColor4 white = SColor4( 255, 255, 255, 255 );
	static immutable SColor4 red = SColor4( 255, 0, 0, 255 );
	static immutable SColor4 green = SColor4( 0, 255, 0, 255 );
	static immutable SColor4 blue = SColor4( 0, 0, 255, 255 );
}