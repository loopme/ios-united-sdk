//
//  LoopMe360ViewController.m
//  LoopMeSDK
//
//  Created by Bohdan on 4/25/16.
//  Copyright © 2016 LoopMe. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import <AVFoundation/AVFoundation.h>
#import "LoopMeGLProgram.h"
#import "LoopMe360ViewController.h"
#import <math.h>

#define MAX_OVERTURE 95.0
#define MIN_OVERTURE 25.0
#define DEFAULT_OVERTURE 85.0
#define GYRO_DELTA 50

#define ES_PI  (3.14159265f)

#define ROLL_CORRECTION ES_PI/2.0

// Color Conversion Constants (YUV to RGB) including adjustment from 16-235/16-240 (video range)
// BT.709, which is the standard for HDTV.
static const GLfloat kColorConversion709[] = {
    1.164,  1.164, 1.164,
    0.0, -0.213, 2.112,
    1.793, -0.533,   0.0,
};

enum {
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_Y,
    UNIFORM_UV,
    UNIFORM_COLOR_CONVERSION_MATRIX,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

@interface LoopMe360ViewController ()

@property (nonatomic) GLKMatrix4 modelViewProjectionMatrix;

@property (nonatomic) GLuint vertexArrayID;
@property (nonatomic) GLuint vertexBufferID;
@property (nonatomic) GLuint vertexIndicesBufferID;
@property (nonatomic) GLuint vertexTexCoordID;
@property (nonatomic) GLuint vertexTexCoordAttributeIndex;

@property (nonatomic) float fingerRotationX;
@property (nonatomic) float fingerRotationY;
@property (nonatomic) CGFloat overture;

@property (nonatomic) int numIndices;

@property (nonatomic) CMAttitude *referenceAttitude;

@property (nonatomic) CVOpenGLESTextureRef lumaTexture;
@property (nonatomic) CVOpenGLESTextureRef chromaTexture;
@property (nonatomic) CVOpenGLESTextureCacheRef videoTextureCache;
@property (nonatomic) const GLfloat *preferredConversion;


@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) LoopMeGLProgram *program;
@property (strong, nonatomic) CMMotionManager *motionManager;

@property (assign, nonatomic) CGFloat gyroDelta;

@end

@implementation LoopMe360ViewController

#pragma mark - Setters

- (void)setFingerRotationY:(float)fingerRotationY {
    _fingerRotationY = fingerRotationY;
    [self movedView];
}

#pragma mark - Life Cycle

- (void)dealloc {
    [self tearDownGL];
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    [view addGestureRecognizer:pinchRecognizer];
    
    self.motionManager = [[CMMotionManager alloc] init];
    
    //Gyroscope
    if ([self.motionManager isDeviceMotionAvailable]) {
        if ([self.motionManager isDeviceMotionActive] == NO) {
            self.motionManager.deviceMotionUpdateInterval = 1.0 / 60.0;
            self.motionManager.gyroUpdateInterval = 1.0 / 60;
            self.motionManager.showsDeviceMovementDisplay = YES;
            
            [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]
                                                    withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
                                                        
                                                        if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
                                                            self.fingerRotationX += motion.rotationRate.x / 60;
                                                            self.fingerRotationY += motion.rotationRate.y / 60;
                                                        } else if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft){
                                                            self.fingerRotationY -= motion.rotationRate.x / 60;
                                                            self.fingerRotationX += motion.rotationRate.y / 60;
                                                        } else if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight) {
                                                            self.fingerRotationY += motion.rotationRate.x / 60;
                                                            self.fingerRotationX -= motion.rotationRate.y / 60;
                                                        }
                                                        
                                                        if (self.gyroDelta < GYRO_DELTA) {
                                                            self.gyroDelta += motion.rotationRate.x;
                                                            self.gyroDelta += motion.rotationRate.y;
                                                            self.gyroDelta += motion.rotationRate.z;
                                                            
                                                            if (self.gyroDelta > GYRO_DELTA) {
                                                                [self.customDelegate track360Gyro];
                                                            }
                                                        }
                                                    }];
            
            
        }
    } else {
        NSLog(@"Gyroscope not Available!");
    }

}

- (void)viewDidLoad {
    [super viewDidLoad];
    _gyroDelta = 0;
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    
    self.preferredFramesPerSecond = 30.0f;
    
    self.overture = DEFAULT_OVERTURE;
    
    // Set the default conversion to BT.709, which is the standard for HDTV.
    self.preferredConversion = kColorConversion709;
    [self setupGL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }
}

#pragma mark - Touches

- (void)pan:(CGPoint)location prevLocation:(CGPoint)prevLocation {
    float distX = location.x - prevLocation.x;
    float distY = location.y - prevLocation.y;
    
    if (fabsf(distX) > 10. || fabsf(distY) > 10.) {
        [self.customDelegate track360Swipe];
    }
    
    distX *= -0.005;
    distY *= -0.005;
    self.fingerRotationX -= distY * self.overture / 100;
    self.fingerRotationY -= distX * self.overture / 100;
}

- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer {
    self.overture /= recognizer.scale;
    
    if (self.overture > MAX_OVERTURE)
        self.overture = MAX_OVERTURE;
    if(self.overture < MIN_OVERTURE)
        self.overture = MIN_OVERTURE;
    
    [self.customDelegate track360Zoom];
}

#pragma mark - Draw

- (void)cleanUpTextures {
    if (self.lumaTexture) {
        CFRelease(self.lumaTexture);
        self.lumaTexture = NULL;
    }
    
    if (self.chromaTexture) {
        CFRelease(self.chromaTexture);
        self.chromaTexture = NULL;
    }
    
    // Periodic texture cache flush every frame
    CVOpenGLESTextureCacheFlush(self.videoTextureCache, 0);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [self.program use];
    
    glBindVertexArrayOES(self.vertexArrayID);
    
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, self.modelViewProjectionMatrix.m);
    
    CVPixelBufferRef pixelBuffer = [self.customDelegate retrievePixelBufferToDraw];
    
    CVReturn err;
    if (pixelBuffer != NULL) {
        int frameWidth = (int)CVPixelBufferGetWidth(pixelBuffer);
        int frameHeight = (int)CVPixelBufferGetHeight(pixelBuffer);
        
        if (!_videoTextureCache) {
            NSLog(@"No video texture cache");
            return;
        }
        
        [self cleanUpTextures];
        
        // Y-plane
        glActiveTexture(GL_TEXTURE0);
        err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                           _videoTextureCache,
                                                           pixelBuffer,
                                                           NULL,
                                                           GL_TEXTURE_2D,
                                                           GL_RED_EXT,
                                                           frameWidth,
                                                           frameHeight,
                                                           GL_RED_EXT,
                                                           GL_UNSIGNED_BYTE,
                                                           0,
                                                           &_lumaTexture);
        if (err) {
            NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
        }
        
        glBindTexture(CVOpenGLESTextureGetTarget(_lumaTexture), CVOpenGLESTextureGetName(_lumaTexture));
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        // UV-plane.
        glActiveTexture(GL_TEXTURE1);
        err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                           _videoTextureCache,
                                                           pixelBuffer,
                                                           NULL,
                                                           GL_TEXTURE_2D,
                                                           GL_RG_EXT,
                                                           frameWidth / 2,
                                                           frameHeight / 2,
                                                           GL_RG_EXT,
                                                           GL_UNSIGNED_BYTE,
                                                           1,
                                                           &_chromaTexture);
        if (err) {
            NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
        }
        
        glBindTexture(CVOpenGLESTextureGetTarget(_chromaTexture), CVOpenGLESTextureGetName(_chromaTexture));
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        CFRelease(pixelBuffer);
        
        glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);
        
        glDrawElements (GL_TRIANGLES, _numIndices,
                        GL_UNSIGNED_SHORT, 0 );
    }
}

#pragma mark - private

- (void)movedView {
    CGFloat degrees = GLKMathRadiansToDegrees(self.fingerRotationY);
    if (degrees > 360) {
        degrees -= 360;
    }
    
    if (degrees < 0) {
        degrees += 360;
    }
    
    if (degrees < 0) {
        degrees += 360;
    }
    
    if (degrees <= 45 || degrees > 315) {
        [self.customDelegate track360FrontSector];
    } else if (degrees > 45 && degrees <= 135){
        [self.customDelegate track360LeftSector];
    } else if (degrees > 135 && degrees <= 225) {
        [self.customDelegate track360BackSector];
    } else if (degrees > 225 && degrees <= 315) {
        [self.customDelegate track360RightSector];
    }
}

- (void)setupGL {
    [EAGLContext setCurrentContext:self.context];
    
    [self buildProgram];
    
    GLfloat *vVertices = NULL;
    GLfloat *vTextCoord = NULL;
    GLushort *indices = NULL;
    int numVertices = 0;
    self.numIndices = esGenSphere(200, 1.0f, &vVertices,  NULL,
                               &vTextCoord, &indices, &numVertices);
    
    glGenVertexArraysOES(1, &_vertexArrayID);
    glBindVertexArrayOES(self.vertexArrayID);
    
    // Vertex
    glGenBuffers(1, &_vertexBufferID);
    glBindBuffer(GL_ARRAY_BUFFER, self.vertexBufferID);
    glBufferData(GL_ARRAY_BUFFER,
                 numVertices*3*sizeof(GLfloat),
                 vVertices,
                 GL_STATIC_DRAW);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition,
                          3,
                          GL_FLOAT,
                          GL_FALSE,
                          sizeof(GLfloat) * 3,
                          NULL);
    
    // Texture Coordinates
    glGenBuffers(1, &_vertexTexCoordID);
    glBindBuffer(GL_ARRAY_BUFFER, self.vertexTexCoordID);
    glBufferData(GL_ARRAY_BUFFER,
                 numVertices*2*sizeof(GLfloat),
                 vTextCoord,
                 GL_DYNAMIC_DRAW);
    glEnableVertexAttribArray(self.vertexTexCoordAttributeIndex);
    glVertexAttribPointer(self.vertexTexCoordAttributeIndex,
                          2,
                          GL_FLOAT,
                          GL_FALSE,
                          sizeof(GLfloat) * 2,
                          NULL);
    
    //Indices
    glGenBuffers(1, &_vertexIndicesBufferID);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self.vertexIndicesBufferID);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER,
                 sizeof(GLushort) * self.numIndices,
                 indices, GL_STATIC_DRAW);
    
    
    if (!self.videoTextureCache) {
        CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, self.context, NULL, &_videoTextureCache);
        if (err != noErr) {
            NSLog(@"Error at CVOpenGLESTextureCacheCreate %d", err);
            return;
        }
    }
    
    [self.program use];
    glUniform1i(uniforms[UNIFORM_Y], 0);
    glUniform1i(uniforms[UNIFORM_UV], 1);
    glUniformMatrix3fv(uniforms[UNIFORM_COLOR_CONVERSION_MATRIX], 1, GL_FALSE, self.preferredConversion);
}

- (void)buildProgram {
    self.program = [[LoopMeGLProgram alloc]
                initWithVertexShaderFilename:@"Shader"
                fragmentShaderFilename:@"Shader"];
    
    [self.program addAttribute:@"position"];
    [self.program addAttribute:@"texCoord"];
    
    if (![self.program link]) {
        NSString *programLog = [self.program programLog];
        NSLog(@"Program link log: %@", programLog);
        NSString *fragmentLog = [self.program fragmentShaderLog];
        NSLog(@"Fragment shader compile log: %@", fragmentLog);
        NSString *vertexLog = [self.program vertexShaderLog];
        NSLog(@"Vertex shader compile log: %@", vertexLog);
        self.program = nil;
        NSAssert(NO, @"Falied to link HalfSpherical shaders");
    }
    
    self.vertexTexCoordAttributeIndex = [self.program attributeIndex:@"texCoord"];
    
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = [self.program uniformIndex:@"modelViewProjectionMatrix"];
    uniforms[UNIFORM_Y] = [self.program uniformIndex:@"SamplerY"];
    uniforms[UNIFORM_UV] = [self.program uniformIndex:@"SamplerUV"];
    uniforms[UNIFORM_COLOR_CONVERSION_MATRIX] = [self.program uniformIndex:@"colorConversionMatrix"];
}


- (void)tearDownGL {
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &_vertexBufferID);
    glDeleteVertexArraysOES(1, &_vertexArrayID);
    glDeleteBuffers(1, &_vertexTexCoordID);
    
    self.program = nil;
    self.videoTextureCache = nil;
}

int esGenSphere(int numSlices, float radius, float **vertices, float **normals,
                float **texCoords, uint16_t **indices, int *numVertices_out) {
    int i;
    int j;
    int numParallels = numSlices / 2;
    int numVertices = ( numParallels + 1 ) * ( numSlices + 1 );
    int numIndices = numParallels * numSlices * 6;
    float angleStep = (2.0f * ES_PI) / ((float) numSlices);
    
    if ( vertices != NULL )
        *vertices = malloc ( sizeof(float) * 3 * numVertices );
    
    if ( texCoords != NULL )
        *texCoords = malloc ( sizeof(float) * 2 * numVertices );
    
    if ( indices != NULL )
        *indices = malloc ( sizeof(uint16_t) * numIndices );
    
    for ( i = 0; i < numParallels + 1; i++ ) {
        for ( j = 0; j < numSlices + 1; j++ ) {
            int vertex = ( i * (numSlices + 1) + j ) * 3;
            
            if ( vertices ) {
                (*vertices)[vertex + 0] = radius * sinf ( angleStep * (float)i ) *
                sinf ( angleStep * (float)j );
                (*vertices)[vertex + 1] = radius * cosf ( angleStep * (float)i );
                (*vertices)[vertex + 2] = radius * sinf ( angleStep * (float)i ) *
                cosf ( angleStep * (float)j );
            }
            
            if (texCoords) {
                int texIndex = ( i * (numSlices + 1) + j ) * 2;
                (*texCoords)[texIndex + 0] = (float) j / (float) numSlices;
                (*texCoords)[texIndex + 1] = 1.0f - ((float) i / (float) (numParallels));
            }
        }
    }
    
    // Generate the indices
    if ( indices != NULL ) {
        uint16_t *indexBuf = (*indices);
        for ( i = 0; i < numParallels ; i++ ) {
            for ( j = 0; j < numSlices; j++ ) {
                *indexBuf++  = i * ( numSlices + 1 ) + j;
                *indexBuf++ = ( i + 1 ) * ( numSlices + 1 ) + j;
                *indexBuf++ = ( i + 1 ) * ( numSlices + 1 ) + ( j + 1 );
                
                *indexBuf++ = i * ( numSlices + 1 ) + j;
                *indexBuf++ = ( i + 1 ) * ( numSlices + 1 ) + ( j + 1 );
                *indexBuf++ = i * ( numSlices + 1 ) + ( j + 1 );
            }
        }
    }
    
    if (numVertices_out) {
        *numVertices_out = numVertices;
    }
    
    return numIndices;
}

- (void)update {
    float aspect = fabs(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(self.overture), aspect, 0.1f, 400.0f);
    projectionMatrix = GLKMatrix4Rotate(projectionMatrix, ES_PI, 0.0f, 0.0f, 1.0f);
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
    modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, 300.0, 300.0, 300.0);
    modelViewMatrix = GLKMatrix4RotateX(modelViewMatrix, self.fingerRotationX);
    modelViewMatrix = GLKMatrix4RotateY(modelViewMatrix, self.fingerRotationY);
    
    self.modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
}

@end
