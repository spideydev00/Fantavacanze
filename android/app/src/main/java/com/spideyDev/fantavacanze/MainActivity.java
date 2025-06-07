package com.spideyDev.fantavacanze;

import io.flutter.embedding.android.FlutterActivity;
import android.os.Bundle;

public class MainActivity extends FlutterActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        // Configure log filters to reduce console noise
        LogFilter.setupLogging();
    }
}
