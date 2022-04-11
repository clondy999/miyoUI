#include <SDL/SDL.h>
#include <SDL/SDL_image.h>

#include <fcntl.h>
#include <linux/fb.h>
#include <sys/ioctl.h>
#include <sys/mman.h>
#include <unistd.h>
#include <linux/input.h>

#define BUTTON_A KEY_SPACE
#define BUTTON_B KEY_LEFTCTRL

int main(int argc , char* argv[]) {
	if (argc<2) {
		puts("Usage: confirm image");
		puts("  then check for a file named OKAY");
		return 0;
	}

	char path[256];
	strncpy(path,argv[1],256);
		
	int fb0_fd = open("/dev/fb0", O_RDWR);
	struct fb_var_screeninfo vinfo;
	ioctl(fb0_fd, FBIOGET_VSCREENINFO, &vinfo);
	int map_size = vinfo.xres * vinfo.yres * (vinfo.bits_per_pixel / 8); // 640x480x4
	char* fb0_map = (char*)mmap(0, map_size, PROT_READ | PROT_WRITE, MAP_SHARED, fb0_fd, 0);
	
	memset(fb0_map, 0, map_size); // clear screen
	
	SDL_Surface* img = IMG_Load(path); // 24-bit opaque png
	
	uint8_t* dst = (uint8_t*)fb0_map; // rgba
	uint8_t* src = (uint8_t*)img->pixels; // bgr
	src += ((img->h * img->w) - 1) * 3;
	for (int y=0; y<img->h; y++) {
		for (int x=0; x<img->w; x++) {
			*(dst+0) = *(src+2); // r
			*(dst+1) = *(src+1); // g
			*(dst+2) = *(src+0); // b
			*(dst+3) = 0xf; // alpha
			dst += 4;
			src -= 3;
		}
	}
	SDL_FreeSurface(img);
	
	unlink("OKAY");
	
	int input_fd = open("/dev/input/event0", O_RDONLY);
	struct input_event	event;
	while (read(input_fd, &event, sizeof(event))==sizeof(event)) {
		if (event.type!=EV_KEY || event.value>1) continue;
		if (event.type==EV_KEY) {
			if (event.code==BUTTON_A) {
				close(open("OKAY", O_RDWR|O_CREAT, 0777)); // basically touch
				break;
			}
			else if (event.code==BUTTON_B) {
				break;
			}
		}
	}
	
	memset(fb0_map, 0, map_size); // clear screen
	
	return EXIT_SUCCESS;
}