//
//  ContentView.swift
//  MotoApp
//
//  Created by Naren Sai Bollineni on 10/17/23.
//

import SwiftUI
import MapKit
import CoreLocation
import AVFoundation
import MediaPlayer

struct ContentView: View {
    var body: some View {
        HStack {
            MusicControlView()
                .frame(maxWidth: .infinity)
            
            MapsView()
                .frame(maxWidth: .infinity)
        }
    }
}

struct MusicControlView: View {
    @State private var musicPlayer = MPMusicPlayerController.systemMusicPlayer
    @State private var currentTime: TimeInterval = 0
    @State private var totalTime: TimeInterval = 0
    @State private var isPlaying: Bool = false

    var body: some View {
        VStack {
            // Album Art
            if let artwork = musicPlayer.nowPlayingItem?.artwork,
               let uiImage = artwork.image(at: CGSize(width: 100, height: 100)) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
            } else {
                Image(systemName: "music.note")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
            }
            
            // Song Title
            Text(fetchCurrentSong())
                .font(.headline)
            
            // Play/Pause Button
            Button(action: togglePlayPause) {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
            }
            
            // Next and Previous Buttons
            HStack {
                Button(action: skipToPrevious) {
                    Image(systemName: "backward.fill")
                }
                
                Button(action: skipToNext) {
                    Image(systemName: "forward.fill")
                }
            }
            
            // Music Scrubber
            Slider(value: $currentTime, in: 0...totalTime, onEditingChanged: sliderEditingChanged)
        }
        .onAppear {
            setupMusicPlayer()
        }
    }
    
    func setupMusicPlayer() {
        // This can be used to set up your music player, fetch total time, etc.
        totalTime = musicPlayer.nowPlayingItem?.playbackDuration ?? 0
    }
    
    func fetchCurrentSong() -> String {
        return musicPlayer.nowPlayingItem?.title ?? "No song is currently playing"
    }
    
    func togglePlayPause() {
        isPlaying.toggle()
        if isPlaying {
            musicPlayer.play()
        } else {
            musicPlayer.pause()
        }
    }
    
    func skipToNext() {
        musicPlayer.skipToNextItem()
        setupMusicPlayer()
    }
    
    func skipToPrevious() {
        musicPlayer.skipToPreviousItem()
        setupMusicPlayer()
    }
    
    func sliderEditingChanged(editingStarted: Bool) {
        if editingStarted {
            // User started interacting with slider - pause playback
            musicPlayer.pause()
        } else {
            // User finished interacting with slider - resume playback
            musicPlayer.currentPlaybackTime = currentTime
            if isPlaying {
                musicPlayer.play()
            }
        }
    }
}


struct MapsView: UIViewRepresentable {
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var showAlert = false
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        
        // Request location access
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Update the view if needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapsView
        
        init(_ parent: MapsView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 5.0
            return renderer
        }
        
        func mapView(_ mapView: MKMapView, didFailToLocateUserWithError error: Error) {
            // Handle location errors
            parent.showAlert = true
        }
    }
}

