import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';

class ProfileRepository {
  final supabase = Supabase.instance.client;

  Future<Profile?> getProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final data = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();

    return Profile.fromJson(data);
  }

  Future<void> updateProfile(Profile profile) async {
    await supabase
        .from('profiles')
        .update(profile.toJson())
        .eq('id', profile.id);
  }
}
