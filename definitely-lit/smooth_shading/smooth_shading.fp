varying mediump vec3 var_normal;
varying highp vec4 frag_pos;

#define LIGHT_COUNT 8

varying mediump vec4 var_light_pos[LIGHT_COUNT];
varying mediump vec4 var_light_color[LIGHT_COUNT];
uniform vec4 tint; // the color of the object
uniform vec4 math_vars; // x = 1; y = 0.09; z = 0.0032 and w = 0

// used in case the object has an ambient light
varying mediump vec4 var_light_dir;
uniform mediump vec4 light_dir_color;
uniform mediump vec4 ambient;

uniform lowp sampler2D tex0; // the texture of the model (in this case, is a 16x16 wooden floor)
varying mediump vec2 var_texcoord;

const float BayerMatrixDim = 8.0;
float Bayer_matrix[64] = {
    0.0/65.0, 32.0/65.0, 8.0/65.0, 40.0/65.0, 2.0/65.0, 34.0/65.0, 10.0/65.0, 42.0/65.0,
    48.0/65.0, 16.0/65.0, 56.0/65.0, 24.0/65.0, 50.0/65.0, 18.0/65.0, 58.0/65.0, 26.0/65.0,
    12.0/65.0, 44.0/65.0, 4.0/65.0, 36.0/65.0, 14.0/65.0, 46.0/65.0, 6.0/65.0, 38.0/65.0,
    60.0/65.0, 28.0/65.0, 52.0/65.0, 20.0/65.0, 62.0/65.0, 30.0/65.0, 54.0/65.0, 22.0/65.0,
    3.0/65.0, 35.0/65.0, 11.0/65.0, 43.0/65.0, 1.0/65.0, 33.0/65.0, 9.0/65.0, 41.0/65.0,
    51.0/65.0, 19.0/65.0, 59.0/65.0, 27.0/65.0, 49.0/65.0, 17.0/65.0, 57.0/65.0, 25.0/65.0,
    15.0/65.0, 47.0/65.0, 7.0/65.0, 39.0/65.0, 13.0/65.0, 45.0/65.0, 5.0/65.0, 37.0/65.0,
    63.0/65.0, 31.0/65.0, 55.0/65.0, 23.0/65.0, 61.0/65.0, 29.0/65.0, 53.0/65.0, 21.0/65.0
};

float ambient_strength = ambient.w;

vec3 light_point_calculation(vec3 light_color, vec4 light_pos, vec3 normal, vec3 frag_pos);
vec3 light_dir_calculation(vec3 light_color, vec4 light_dir, vec3 normal);

void main()
{
    vec4 tex = vec4(texture(tex0, var_texcoord));
    if(tex.w == 0)
        discard;

    vec3 result;

    result = light_dir_calculation(light_dir_color.rgb, var_light_dir, var_normal);
    for(int i = 0; i < LIGHT_COUNT; i++)
    {
        if(var_light_color[i].w != 0)
            result += light_point_calculation(var_light_color[i].rgb, var_light_pos[i], var_normal, frag_pos.xyz);
    }
    
    gl_FragColor = vec4(result, 1);
}

vec3 light_dir_calculation(vec3 light_color, vec4 light_dir, vec3 normal)
{
    // Diffuse light calculations
    vec3 var_ambient = ambient_strength * (vec3(texture(tex0, var_texcoord)) * ambient.rgb);

    // diffuse
    float diff = max(dot(normal, light_dir.xyz), 0.0) * light_dir.a;
    vec3 diffuse = diff * light_color * vec3(texture(tex0, var_texcoord));
 
    return (diffuse + var_ambient);
}

vec3 light_point_calculation(vec3 light_color, vec4 light_pos, vec3 normal, vec3 frag_pos)
{
    // Diffuse light calculations
    vec3 var_ambient = ambient_strength * (vec3(texture(tex0, var_texcoord)) * ambient.rgb);
  	
    // diffuse 
    vec3 light_dir = normalize(light_pos.xyz - frag_pos);
    float diff = max(dot(normal, light_dir), 0.0) * light_pos.a;
    vec3 diffuse = diff * light_color * vec3(texture(tex0, var_texcoord));

    float light_distance = length(light_pos.xyz - frag_pos);
    float attenuation = 1.0 / (1 + 0.9 * light_distance + 0.0032 * (light_distance * light_distance));

    var_ambient *= attenuation;
    diffuse *= attenuation;
 
    return (diffuse + var_ambient);
}