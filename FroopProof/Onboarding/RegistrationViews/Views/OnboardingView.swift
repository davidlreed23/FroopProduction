import SwiftUI

struct OnboardingView: View {
    var body: some View {
        TabView {
            ProfileCompletionView1()
                .tag(0)
            ProfileCompletionView2()  // Make sure to implement this view similarly to `ProfileCompletionView1`
                .tag(1)
            ProfileCompletionView3()  // Implement this
                .tag(2)
            ProfileCompletionView4()  // Implement this
                .tag(3)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))  // This makes it a swipe view without showing the page dots
    }
}
