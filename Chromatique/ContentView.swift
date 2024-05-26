import SwiftUI
import MediaPlayer
import Combine

struct ContentView: View {
    private let colors: [Color] = [.black, .red, .green, .blue, .yellow, .orange, .purple]
    private let gradientKey = "isGradientViewActive"
    private let mediaInfoKey = "showMediaInfo"
    private let selectedColorKey = "selectedColorIndex"
    private let firstTimeKey = "isFirstTime"

    @State private var selectedColor: Color = .black
    @State private var isMenuOpen: Bool = false
    @State private var isGradientViewActive: Bool = false
    @State private var showMediaInfo: Bool = false
    @State private var showTutorial: Bool = false
    @State private var transitionInProgress: Bool = false
    @FocusState private var focusedCircleIndex: Int?
    @State private var nowPlayingItem: MPMediaItem?
    @State private var timer: Timer?

    var body: some View {
        ZStack {
            if isGradientViewActive {
                GradientView()
                    .edgesIgnoringSafeArea(.all)
                    .zIndex(0)
            } else {
                selectedColor
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.5), value: selectedColor)
                    .zIndex(0)
            }

            VStack {
                Spacer()

                if showMediaInfo {
                    MediaInfoView(nowPlayingItem: nowPlayingItem)
                        .padding(40)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(100)
                        .transition(.scale)
                        .zIndex(1)
                }

                if isMenuOpen {
                    HStack {
                        Circle()
                            .fill(Color.clear)
                            .frame(width: 50, height: 50)
                            .overlay(
                                Image(systemName: "music.note")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.white)
                            )
                            .overlay(
                                Circle()
                                    .stroke(showMediaInfo ? Color.white : Color.clear, lineWidth: 4)
                                    .animation(.easeInOut(duration: 0.2), value: showMediaInfo)
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.white, style: StrokeStyle(lineWidth: 4, dash: [3]))
                                    .opacity(focusedCircleIndex == -1 ? 1 : 0)
                                    .animation(.easeInOut(duration: 0.2), value: focusedCircleIndex == -1)
                            )
                            .focusable()
                            .focused($focusedCircleIndex, equals: -1)
                            .scaleEffect(focusedCircleIndex == -1 ? 1.2 : 1.0)
                            .onTapGesture {
                                guard !transitionInProgress else { return }
                                withAnimation {
                                    showMediaInfo.toggle()
                                    saveMediaInfoState()
                                }
                            }

                        ForEach(colors.indices, id: \.self) { index in
                            Circle()
                                .fill(colors[index])
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Circle()
                                        .stroke((selectedColor == colors[index] && !isGradientViewActive) ? Color.white : Color.clear, lineWidth: 4)
                                        .animation(.easeInOut(duration: 0.2), value: selectedColor == colors[index])
                                )
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, style: StrokeStyle(lineWidth: 4, dash: [3]))
                                        .opacity(focusedCircleIndex == index && selectedColor != colors[index] ? 1 : 0)
                                        .animation(.easeInOut(duration: 0.2), value: focusedCircleIndex == index)
                                )
                                .scaleEffect(focusedCircleIndex == index ? 1.2 : 1.0)
                                .focusable()
                                .focused($focusedCircleIndex, equals: index)
                                .onTapGesture {
                                    guard !transitionInProgress else { return }
                                    withAnimation {
                                        selectedColor = colors[index]
                                        isGradientViewActive = false
                                        isMenuOpen = false
                                        saveSelectedColorState(index: index)
                                        saveGradientViewState(isActive: false)
                                        endTransition(after: 0.5)
                                    }
                                }
                        }

                        Circle()
                            .fill(Color.clear)
                            .frame(width: 50, height: 50)
                            .overlay(
                                Image("gradient")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                            )
                            .overlay(
                                Circle()
                                    .stroke(isGradientViewActive ? Color.white : Color.clear, lineWidth: 4)
                                    .animation(.easeInOut(duration: 0.2), value: isGradientViewActive)
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.white, style: StrokeStyle(lineWidth: 4, dash: [3]))
                                    .opacity(focusedCircleIndex == colors.count ? 1 : 0)
                                    .animation(.easeInOut(duration: 0.2), value: focusedCircleIndex == colors.count)
                            )
                            .scaleEffect(focusedCircleIndex == colors.count ? 1.2 : 1.0)
                            .focusable()
                            .focused($focusedCircleIndex, equals: colors.count)
                            .onTapGesture {
                                guard !transitionInProgress else { return }
                                withAnimation {
                                    isGradientViewActive = true
                                    isMenuOpen = false
                                    saveGradientViewState(isActive: true)
                                    endTransition(after: 0.5)
                                }
                            }
                    }
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(40)
                    .zIndex(2)
                }

                Spacer()
            }
            .zIndex(3)

            if showTutorial {
                TutorialOverlay(showTutorial: $showTutorial)
                    .zIndex(4)
            }
        }
        .onAppear {
            loadSavedState()
            startTimer()
            startObservingNowPlayingItem()
            if isMenuOpen {
                focusedCircleIndex = isGradientViewActive ? colors.count : (colors.firstIndex(of: selectedColor) ?? nil)
            }
            if UserDefaults.standard.bool(forKey: firstTimeKey) == false {
                showTutorial = true
                UserDefaults.standard.set(true, forKey: firstTimeKey)
            }
        }
        .onDisappear {
            stopTimer()
            stopObservingNowPlayingItem()
        }
        .onChange(of: isMenuOpen) { oldIsOpen, newIsOpen in
            if newIsOpen {
                focusedCircleIndex = isGradientViewActive ? colors.count : (colors.firstIndex(of: selectedColor) ?? nil)
            }
        }
        .pressable { event in
            guard !transitionInProgress else { return }
            if event == .select {
                startTransition()
                withAnimation {
                    isMenuOpen.toggle()
                    focusedCircleIndex = nil
                }
                endTransition(after: 0.5)
            }
        }
        .onMoveCommand { direction in
            guard !transitionInProgress else { return }
            withAnimation {
                isMenuOpen = true
                focusedCircleIndex = isGradientViewActive ? colors.count : (colors.firstIndex(of: selectedColor) ?? nil)
            }
        }
        .disableIdleTimer()
    }

    func startTransition() {
        transitionInProgress = true
    }

    func endTransition(after delay: Double? = nil) {
        if let delay = delay {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                transitionInProgress = false
            }
        } else {
            transitionInProgress = false
        }
    }

    func saveSelectedColorState(index: Int) {
        UserDefaults.standard.set(index, forKey: selectedColorKey)
    }

    func saveGradientViewState(isActive: Bool) {
        UserDefaults.standard.set(isActive, forKey: gradientKey)
    }

    func saveMediaInfoState() {
        UserDefaults.standard.set(showMediaInfo, forKey: mediaInfoKey)
    }

    func loadSavedState() {
        let selectedIndex = UserDefaults.standard.integer(forKey: selectedColorKey)
        selectedColor = colors[selectedIndex]
        isGradientViewActive = UserDefaults.standard.bool(forKey: gradientKey)
        showMediaInfo = UserDefaults.standard.bool(forKey: mediaInfoKey)
    }

    func startTimer() {
        fetchNowPlayingItem()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            fetchNowPlayingItem()
        }
    }

    func stopTimer() {
        timer?.invalidate()
    }

    func fetchNowPlayingItem() {
        let systemMusicPlayer = MPMusicPlayerController.systemMusicPlayer
        if let nowPlaying = systemMusicPlayer.nowPlayingItem {
            if !areItemsEqual(nowPlaying, nowPlayingItem) {
                nowPlayingItem = nowPlaying
            }
        } else {
            if nowPlayingItem != nil {
                nowPlayingItem = nil
            }
        }
    }

    func areItemsEqual(_ item1: MPMediaItem?, _ item2: MPMediaItem?) -> Bool {
        guard let item1 = item1, let item2 = item2 else {
            return item1 == nil && item2 == nil
        }
        return item1.persistentID == item2.persistentID
    }

    func startObservingNowPlayingItem() {
        NotificationCenter.default.addObserver(forName: .MPMusicPlayerControllerNowPlayingItemDidChange, object: MPMusicPlayerController.systemMusicPlayer, queue: .main) { _ in
            fetchNowPlayingItem()
        }
        MPMusicPlayerController.systemMusicPlayer.beginGeneratingPlaybackNotifications()
    }

    func stopObservingNowPlayingItem() {
        NotificationCenter.default.removeObserver(self, name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: MPMusicPlayerController.systemMusicPlayer)
        MPMusicPlayerController.systemMusicPlayer.endGeneratingPlaybackNotifications()
    }
}
