shader_type canvas_item; //FROM GAMMAGAMES: BY COWTHING ON REDDIT

uniform vec4 shine_color : source_color = vec4(1.0);
uniform vec4 base_color : source_color = vec4(1.0);
uniform int pixel_size = 32;
uniform float shine_speed : hint_range(0.0, 10.0, 0.1) = 1.0;
uniform float shine_size : hint_range(0.01, 1.0, 0.01) = 0.01;
uniform bool shine_bool = false;

void fragment() {
	if (shine_bool == true) {
		vec2 grid_uv = round(UV * float(pixel_size)) / float(pixel_size);
		COLOR = texture(TEXTURE, grid_uv);
		float shine = step(1.0 - shine_size * 0.5, 0.5 + 0.5 * sin(grid_uv.x - grid_uv.y + TIME * shine_speed));
		COLOR.rgb = mix(COLOR.rgb, shine_color.rgb, shine * shine_color.a);
		COLOR.rgb = mix(base_color.rgb, shine_color.rgb, shine * shine_color.a);
		}
}