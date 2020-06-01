#include "mex.h"
#include "math.h"
#include <stdlib.h>

/* Input Arguments */
#define	X_size_fin			prhs[0]
#define	Y_size_fin          prhs[1]
#define	Window_side         prhs[2]
#define	Stereo_diff         prhs[3]
// buffer
#define	Im_in_remap         prhs[4]

#define	Output_image        prhs[5]


// PADDING
int index_y(int y, int height)
	{
	if (0 <= y && y < height)
		return y;
    else if (y < 0)
        return 0;
    else
        return height-1;
	}
int index_x(int x, int width)
	{
	if (0 <= x && x < width)
		return x;
    else if (x < 0)
        return 0;
    else
        return width-1;
    }

void remapping
        (
        double * im_in_remap,
        double * output_image,
        unsigned short width,
        unsigned short height,
        unsigned short window_side,
        unsigned short stereo_diff
        )
    {
    int                 x,y                                             ;
    int                 i,j                                             ;
    int                 x_ind,y_ind                                     ;
    unsigned int        x_index_remap,y_index_remap                     ;
    double              interp_color_R    ;
    double              output_color_R    ;
    unsigned int        height_of_remap, width_of_remap, pixels_of_remap;
    int                 window_size                                     ;
    
    window_size = window_side*window_side               ;
    
    height_of_remap = height*window_side                ;
    width_of_remap  = width*window_side                 ;
    pixels_of_remap = height_of_remap*width_of_remap    ;
    
    for (x = 0; x < width; ++x)
        for (y = 0; y < height; ++y)
        {
        output_color_R =0;
        
        
        for (i = -stereo_diff; i < stereo_diff+1; ++i)
            for (j = -stereo_diff; j < stereo_diff+1; ++j)
            {
            x_ind   = i+stereo_diff + (x)*window_side   ;
            y_ind   = j+stereo_diff + (y)*window_side   ;

            
            interp_color_R = im_in_remap[y_ind+x_ind*height_of_remap+0*pixels_of_remap];
            
           
            
            // DEFOCUS ANALYSIS
            output_color_R = interp_color_R + output_color_R;
            
            }
            output_image[y + x * height + 0 * height*width] = output_color_R;
        
        }
    }


void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[])

	{ 
	double *x_size_fin_pt, *y_size_fin_pt, *window_side_pt, *stereo_diff_pt, *im_in_remap_pt,  *output_image_pt;

	/* Check for proper number of arguments */

	if (nrhs != 6)  
		mexErrMsgTxt("Eight input arguments required."); 
	else if (nlhs > 1)
		mexErrMsgTxt("Too many output arguments."); 
 
	
    
	/* Assign pointers to the various parameters */ 
	x_size_fin_pt           = (double *) mxGetPr(X_size_fin)    ;
	y_size_fin_pt           = (double *) mxGetPr(Y_size_fin)    ;
	window_side_pt          = (double *) mxGetPr(Window_side)   ;
	stereo_diff_pt          = (double *) mxGetPr(Stereo_diff)   ;
    im_in_remap_pt          = (double *) mxGetPr(Im_in_remap)   ;
    output_image_pt         = (double *) mxGetPr(Output_image)  ;

	/* Do the actual computations in a subroutine */
    remapping
        (
        im_in_remap_pt,
        output_image_pt,
        *x_size_fin_pt,
        *y_size_fin_pt,
        *window_side_pt,
        *stereo_diff_pt
        );
            
    
	return;
	}