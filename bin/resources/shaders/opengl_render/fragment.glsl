#version 330 core
in vec3 ourColor;
in vec2 TexCoord;
uniform vec4 modulateColor;

out vec4 color;

uniform sampler2D ourTexture;

void main() {
    color = texture( ourTexture, TexCoord ) * modulateColor;
}