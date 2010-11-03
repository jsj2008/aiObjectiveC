//
//  Shader.m
//  aiObjectiveC
//
//  Created by Jørgen P. Tjernø on 11/2/10.
//  Copyright 2010 devSoft. All rights reserved.
//

#import "Shader.h"

#import "GLErrorChecking.h"

@implementation Shader

+ (id) shaderOfType:(GLenum)theShaderType
         fromString:(NSString *)shaderString
{
    return [[[self alloc] initWithType:theShaderType
                            fromString:shaderString] autorelease];
}

- (id) initWithType:(GLenum)theShaderType
         fromString:(NSString *)shaderString
{
    if (self = [super init])
    {
        glClearErrors();

        shaderType = theShaderType;
        shaderId = glCreateShader(theShaderType);
        if (!shaderId || glHasError())
        {
            [self release];
            self = nil;
        }
        else if (![self setSource:shaderString])
        {
            [self release];
            self = nil;
        }
    }

    return self;
}

- (void) dealloc
{
    if (shaderId)
        glDeleteShader(shaderId);
    
    [super dealloc];
}

- (NSString *) source
{
    glClearErrors();

    GLint length;
    glGetShaderiv(shaderId, GL_SHADER_SOURCE_LENGTH, &length);
    if (glHasError())
        return nil;
    
    GLchar *sourceCstring = (GLchar *)malloc(length * sizeof(GLchar));
    glGetShaderSource(shaderId, length * sizeof(GLchar), NULL, sourceCstring);
    if (glHasError())
    {
        free(sourceCstring);
        return nil;
    }

    NSString *source = [NSString stringWithCString:sourceCstring
                                          encoding:NSASCIIStringEncoding];
    free(sourceCstring);

    return source;
}

- (BOOL) setSource:(NSString *)shaderString
{
    glClearErrors();

    const char *source = [shaderString cStringUsingEncoding:NSASCIIStringEncoding];
    glShaderSource(shaderId, 1, &source, NULL);
    
    if (glHasError())
        return NO;
    
    glCompileShader(shaderId);
    if (glHasError())
        return NO;
    
    GLint status;
    glGetShaderiv(shaderId, GL_COMPILE_STATUS, &status);
    if (glHasError())
        return NO;

    return YES;
}

- (NSString *) log
{
    
    GLint length;
    glGetShaderiv(shaderId, GL_INFO_LOG_LENGTH, &length);
    if (glHasError())
        return nil;
    
    GLchar *logCstring = (GLchar *)malloc(length * sizeof(GLchar));
    glGetShaderInfoLog(shaderId, length * sizeof(GLchar), NULL, logCstring);
    if (glHasError())
    {
        free(logCstring);
        return nil;
    }
    
    NSString *log = [NSString stringWithCString:logCstring
                                       encoding:NSASCIIStringEncoding];
    free(logCstring);
    
    return log;
}

- (BOOL) attachToProgram:(GLuint)programId
{
    glClearErrors();
    
    glAttachShader(programId, shaderId);
    return !glHasError();
}

- (BOOL) detachFromProgram:(GLuint)programId
{
    glClearErrors();
    
    glDetachShader(programId, shaderId);
    return !glHasError();    
}

@end
