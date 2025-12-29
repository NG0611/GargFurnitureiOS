import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine



final class SessionStore: ObservableObject {
    @Published var user: UserProfile? = nil
    private var handle: AuthStateDidChangeListenerHandle?

    init() {
        listen()
    }

    func listen() {
        if let h = handle { Auth.auth().removeStateDidChangeListener(h) }

        handle = Auth.auth().addStateDidChangeListener { [weak self] (_, firebaseUser) in
            guard let self = self else { return }

            if let fu = firebaseUser {
                self.loadUser(uid: fu.uid)
            } else {
                DispatchQueue.main.async { self.user = nil }
            }
        }
    }

    // ⭐ Load profile and then addresses
    func loadUser(uid: String) {
        let db = Firestore.firestore()

        db.collection("users").document(uid).getDocument { snap, err in
            let data = snap?.data() ?? [:]

            let profile = UserProfile(
                uid: uid,
                email: data["email"] as? String ?? "",
                name: data["name"] as? String ?? "",
                phone: data["phone"] as? String ?? "",
                addresses: []
            )

            DispatchQueue.main.async {
                self.user = profile
                self.loadAddresses()       // ⭐ address load hota hai yahan
            }
        }
    }

    // ⭐ Load address subcollection
    func loadAddresses() {
        guard let uid = user?.uid else { return }

        Firestore.firestore()
            .collection("users")
            .document(uid)
            .collection("addresses")
            .addSnapshotListener { snap, err in

                if let docs = snap?.documents {
                    let addrs = docs.compactMap { try? $0.data(as: Address.self) }
                    DispatchQueue.main.async {
                        self.user?.addresses = addrs
                    }
                }
            }
    }

    func signOut() {
        try? Auth.auth().signOut()
        self.user = nil
    }
}

// ⭐ Save minimal profile (addresses NOT stored here)
extension SessionStore {
    func saveProfile(_ profile: UserProfile, completion: ((Error?) -> Void)? = nil) {
        let data: [String: Any] = [
            "name": profile.name,
            "email": profile.email,
            "phone": profile.phone ?? ""
        ]

        Firestore.firestore()
            .collection("users")
            .document(profile.uid)
            .setData(data, merge: true, completion: completion)
    }
}
