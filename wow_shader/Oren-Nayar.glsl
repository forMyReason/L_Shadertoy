// The MIT License
// Copyright © 2014 Inigo Quilez
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

float OrenNayar( in vec3 l, in vec3 n, in vec3 v, float r )
{
    float r2 = r*r;
    float a = 1.0 - 0.5*(r2/(r2+0.57));
    float b = 0.45*(r2/(r2+0.09));

#if 1
    // my version
    float nv = max(-dot(v, n),0.0); 
    float nl = max( dot(n, l),0.0); 
    float k = sqrt( (1.0-nv*nv)*(1.0-nl*nl) );
    float ga = max(nv*nl+k,0.0);
    return nl * (a + b*ga*k/max(nv,nl));
#else
    // original trigonometric version
    float nv = max(-dot(v,n), 0.0); 
    float nl = max( dot(n,l), 0.0);
    float angleVN = acos(nv);
    float angleLN = acos(nl);
    float alpha = max(angleVN, angleLN);
    float beta  = min(angleVN, angleLN);
    float gamma = cos(angleVN - angleLN);
    float c = sin(alpha) * tan(beta);
    return nl * (a+(b*max(0.0, gamma)*c));
#endif
}

float Lambert( in vec3 l, in vec3 n )
{
    float nl = dot(n, l);
    return max(0.0,nl);
}

//-----------------------------------------------------------------

float iSphere( in vec3 ro, in vec3 rd, in vec4 sph )
{
	vec3 oc = ro - sph.xyz;
	float b = dot( oc, rd );
	float c = dot( oc, oc ) - sph.w*sph.w;
	float h = b*b - c;
	if( h<0.0 ) return -1.0;
	return -b - sqrt( h );
}

float ssSphere( in vec3 ro, in vec3 rd, in vec4 sph )
{
    vec3 oc = sph.xyz - ro;
    float b = dot( oc, rd );
	
    float res = 1.0;
    if( b>0.0 ) // este branch se puede quitar seguramente
    {
        float h = dot(oc,oc) - b*b - sph.w*sph.w;
        res = clamp( 16.0*h/b, 0.0, 1.0 );
    }
    return res;
}

float oSphere( in vec3 pos, in vec3 nor, in vec4 sph )
{
    vec3 di = sph.xyz - pos;
    float l = length(di);
    return 1.0 - max(0.0,dot(nor,di/l))*sph.w*sph.w/(l*l); 
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 p = (2.0*fragCoord-iResolution.xy)/iResolution.y;

    float an = 0.5 + iTime;
	vec3 lig = normalize( vec3( cos(an), 0.5, sin(an)) );
	vec3 bac = normalize( vec3(-lig.x, 0.0,-lig.z) );
	
    // camera movement	
	vec3 ro = vec3( 1.5*p.x, 1.5*p.y+2.0, 12.0 );
	vec3 rd = normalize(vec3(0.0,-0.1,-1.0));

    // sphere center	
	const vec4 sph1 = vec4(-1.2,1.0,0.0,1.0);
	const vec4 sph2 = vec4( 1.2,1.0,0.0,1.0);

    // raytrace
	float tmin = 10000.0;
	vec3  pos = vec3(0.0);
	vec3  nor = vec3(0.0);
	float occ = 1.0;
	float obj = 0.0;
	
	// raytrace-plane
	float h = (0.0-ro.y)/rd.y;
	if( h>0.0 )
	{
		tmin = h;
		nor = vec3(0.0,1.0,0.0);
		pos = ro + h*rd;
		occ = oSphere( pos, nor, sph1 ) * oSphere( pos, nor, sph2 );
	    obj = 0.0;
	}
	// raytrace-sphere 1
	h = iSphere( ro, rd, sph1 );
	if( h>0.0 && h<tmin ) 
	{ 
		tmin = h; 
		pos = ro + h*rd;
		nor = normalize(pos-sph1.xyz); 
		occ = (0.5 + 0.5*nor.y) * oSphere( pos, nor, sph2 );
	    obj = 1.0;
	}
	// raytrace-sphere 2
	h = iSphere( ro, rd, sph2 );
	if( h>0.0 && h<tmin ) 
	{ 
		tmin = h; 
		pos = ro + h*rd;
		nor = normalize(pos-sph2.xyz); 
		occ = (0.5 + 0.5*nor.y) *oSphere( pos, nor, sph1 );
	    obj = 2.0;
	}

    // shading/lighting	
	vec3 col = vec3(0.93);
	if( tmin<100.0 )
	{
        // shadows
		float sha = 1.0;
		sha *= ssSphere( pos, lig, sph1 );
		sha *= ssSphere( pos, lig, sph2 );

		vec3 lin = vec3(0.0);
		
		// integrate irradiance with brdf times visibility
		vec3 diffColor = vec3(0.18);
		if( obj>1.5 )
		{
            const float re = 0.95;  // 0.0 is same as lambert
            lin += vec3(0.5,0.7,1.0)*diffColor*occ;
	        lin += vec3(5.0,4.5,4.0)*diffColor*OrenNayar( lig, nor, rd, re )*sha;
	        lin += vec3(1.0,1.0,1.0)*diffColor*OrenNayar( bac, nor, rd, re )*occ;
		}
		else
		{
            lin += vec3(0.5,0.7,1.0)*diffColor*occ;
	        lin += vec3(5.0,4.5,4.0)*diffColor*Lambert( lig, nor )*sha;
	        lin += vec3(1.0,1.0,1.0)*diffColor*Lambert( bac, nor )*occ;
		}

		col = lin;
	}
	
    // gamma	
	col = pow( col, vec3(0.4545) );
	
	fragColor = vec4( col, 1.0 );
}