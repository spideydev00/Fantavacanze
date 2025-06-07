package com.spideyDev.fantavacanze;

import android.util.Log;

public class LogFilter {
    // Tag for logs from this class
    private static final String TAG = "LogFilter";
    
    // Flag to enable/disable filters (useful during debugging)
    private static final boolean ENABLE_FILTERS = true;
    
    /**
     * Configure log filters for the application
     */
    public static void setupLogging() {
        if (!ENABLE_FILTERS) return;
        
        try {
            // Set log level for classes that generate too many logs
            setTagLoggingLevel("AudioTrack", Log.ERROR);
            setTagLoggingLevel("AudioTrack-JNI", Log.ERROR);
            setTagLoggingLevel("AudioManager", Log.ERROR);
            setTagLoggingLevel("PlayerBase", Log.ERROR);
            setTagLoggingLevel("BufferPoolManager", Log.ERROR);
            setTagLoggingLevel("CCodecConfig", Log.ERROR);
            setTagLoggingLevel("CCodecBufferChannel", Log.ERROR);
            setTagLoggingLevel("Codec2Client", Log.ERROR);
            setTagLoggingLevel("Codec2-block_helper", Log.ERROR);
            setTagLoggingLevel("CCodec", Log.ERROR);
            setTagLoggingLevel("VideoCapabilities", Log.ERROR);
            
            // Filters specific to Google Mobile Ads
            setTagLoggingLevel("Ads", Log.WARN);
            setTagLoggingLevel("ExoPlayerImpl", Log.WARN);
            
            Log.i(TAG, "Log filters applied successfully");
        } catch (Exception e) {
            Log.e(TAG, "Failed to setup log filters", e);
        }
    }
    
    /**
     * Set log level for a specific tag
     */
    private static void setTagLoggingLevel(String tag, int level) {
        try {
            // Use system properties to configure log level
            String logLevelProperty = "log.tag." + tag;
            
            // Convert log level to string
            String logLevelValue;
            switch (level) {
                case Log.VERBOSE: logLevelValue = "VERBOSE"; break;
                case Log.DEBUG: logLevelValue = "DEBUG"; break;
                case Log.INFO: logLevelValue = "INFO"; break;
                case Log.WARN: logLevelValue = "WARN"; break;
                case Log.ERROR: logLevelValue = "ERROR"; break;
                default: logLevelValue = "SILENT"; break;
            }
            
            System.setProperty(logLevelProperty, logLevelValue);
        } catch (Exception e) {
            Log.e(TAG, "Failed to set log level for tag: " + tag, e);
        }
    }
}
