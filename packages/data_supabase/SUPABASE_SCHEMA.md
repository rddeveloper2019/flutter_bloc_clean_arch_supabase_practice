# Supabase Backend Setup Guide

This document contains all the SQL code for configuring the backend of the **Community Board App**.

---

## 📑 Table of Contents
- [Supabase Backend Setup Guide](#supabase-backend-setup-guide)
  - [📑 Table of Contents](#-table-of-contents)
  - [Tables](#tables)
    - [1. profiles table](#1-profiles-table)
    - [2. posts table](#2-posts-table)
    - [3. comments table](#3-comments-table)
    - [4. likes table](#4-likes-table)
  - [Row Level Security (RLS)](#row-level-security-rls)
    - [1. profiles table RLS](#1-profiles-table-rls)
    - [2. posts table RLS](#2-posts-table-rls)
    - [3. comments table RLS](#3-comments-table-rls)
    - [4. likes table RLS](#4-likes-table-rls)
    - [5. post-images storage RLS](#5-post-images-storage-rls)
    - [6. avatars storage RLS](#6-avatars-storage-rls)
  - [Functions and Triggers](#functions-and-triggers)
    - [1. get\_user\_role](#1-get_user_role)
    - [2. is\_admin](#2-is_admin)
    - [3. handle\_new\_user](#3-handle_new_user)
    - [4. trigger\_set\_timestamp](#4-trigger_set_timestamp)
    - [5. update\_comments\_count](#5-update_comments_count)
    - [6. update\_likes\_count](#6-update_likes_count)
    - [7. handle\_like](#7-handle_like)
    - [8. update\_user\_profile](#8-update_user_profile)
    - [9. get\_my\_posts](#9-get_my_posts)
    - [10. search\_posts](#10-search_posts)
    - [11. create\_post\_and\_return\_post\_display\_view](#11-create_post_and_return_post_display_view)
    - [12. update\_post\_and\_return\_post\_display\_view](#12-update_post_and_return_post_display_view)
    - [13. create\_comment\_and\_return\_comment\_display\_view](#13-create_comment_and_return_comment_display_view)
    - [14. update\_comment\_and\_return\_comment\_display\_view](#14-update_comment_and_return_comment_display_view)
  - [Views](#views)
    - [1. post\_display\_view](#1-post_display_view)
    - [2. comment\_display\_view](#2-comment_display_view)
  - [Indexes](#indexes)
    - [1. index for full-text search](#1-index-for-full-text-search)
  - [Misc.](#misc)
    - [1. update role to admin](#1-update-role-to-admin)

## Tables

### 1. profiles table
```sql
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username TEXT UNIQUE NOT NULL,
  avatar_url TEXT,
  role TEXT NOT NULL DEFAULT 'user',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

### 2. posts table
```sql
CREATE TABLE public.posts (
  id UUID PRIMARY KEY,
  author_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  image_url TEXT,
  likes_count INT NOT NULL DEFAULT 0,
  comments_count INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

### 3. comments table
```sql
CREATE TABLE public.comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID NOT NULL REFERENCES public.posts(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

### 4. likes table
```sql
CREATE TABLE public.likes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID NOT NULL REFERENCES public.posts(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT unique_like UNIQUE (post_id, user_id)
);
```

## Row Level Security (RLS)
### 1. profiles table RLS
```sql
-- Enable RLS for profiles table
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- SELECT policy
-- Any logged-in user can read anyone else's profile information
CREATE POLICY "Allow authenticated users to read all profile information"
ON public.profiles
FOR SELECT
TO authenticated -- the policy applies to all users who are 'authenticated', i.e., logged in
USING (true);

-- UPDATE Policy
-- Users can only update their own profile.
CREATE POLICY "User can update own profile"
ON public.profiles
FOR UPDATE
TO authenticated
USING ((SELECT auth.uid()) = id)
WITH CHECK ((SELECT auth.uid()) = id);

-- First, revoke all ‘UPDATE’ privileges for the entire table.
REVOKE UPDATE ON public.profiles FROM authenticated;

-- Grant permission to update only the necessary columns again.
GRANT UPDATE (username, avatar_url) ON public.profiles TO authenticated;
```

### 2. posts table RLS
```sql
-- Enable RLS on the posts table
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;

-- SELECT Policy
-- Allow authenticated users to read all posts
CREATE POLICY "Allow authenticated users to read all posts"
ON public.posts
FOR SELECT
TO authenticated
USING (true);

-- INSERT Policy
-- Only administrators are allowed to create posts.
CREATE POLICY "Allow admin to create posts"
ON public.posts
FOR INSERT
TO authenticated
WITH CHECK (
  public.get_user_role((SELECT auth.uid())) = 'admin' AND
  author_id = (SELECT auth.uid())
);

-- UPDATE Policy
-- Only administrators are allowed to update own posts.
CREATE POLICY "Allow admin to update own posts"
ON public.posts
FOR UPDATE
TO authenticated 
USING ((SELECT auth.uid()) = author_id AND public.get_user_role((SELECT auth.uid())) = 'admin')
WITH CHECK ((SELECT auth.uid()) = author_id AND public.get_user_role((SELECT auth.uid())) = 'admin');

-- DELETE Policy
-- Only administrators are allowed to delete own posts.
CREATE POLICY "Allow admin to delete own posts"
ON public.posts
FOR DELETE
TO authenticated 
USING ((SELECT auth.uid()) = author_id AND public.get_user_role((SELECT auth.uid())) = 'admin');
```

### 3. comments table RLS
```sql
-- Enable RLS on the comments table
ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;

-- SELECT Policy
-- Authenticated users can view all comments.
CREATE POLICY "Allow authenticated users to read all comments"
ON public.comments
FOR SELECT
TO authenticated -- Applies to the ‘authenticated’ role
USING (true);

-- INSERT Policy
-- Authenticated users can create comments, and the user_id must be their own.
CREATE POLICY "Allow authenticated users to create comments"
ON public.comments
FOR INSERT
TO authenticated -- Roles that can attempt INSERT (authenticated users)
WITH CHECK (user_id = (SELECT auth.uid()));

-- UPDATE Policy
-- Users can only edit their own comments.
CREATE POLICY "Allow users to update their own comments"
ON public.comments
FOR UPDATE
TO authenticated -- Roles that can attempt UPDATE
USING (user_id = (SELECT auth.uid()))
WITH CHECK (user_id = (SELECT auth.uid()));

-- DELETE Policy
-- Users can delete their own comments.
CREATE POLICY "Allow users to delete their own comments"
ON public.comments
FOR DELETE
TO authenticated -- Roles that can attempt DELETE
USING (user_id = (SELECT auth.uid()));

-- Administrators can delete all comments.
CREATE POLICY "Allow admin to delete any comments"
ON public.comments
FOR DELETE
TO authenticated -- Roles that can attempt DELETE (administrators are also authenticated users)
USING (public.get_user_role((SELECT auth.uid())) = 'admin');
```

### 4. likes table RLS
```sql
-- Enable RLS on the likes table
ALTER TABLE public.likes ENABLE ROW LEVEL SECURITY;

-- SELECT Policy
-- Authenticated users can view all “Like” information.
CREATE POLICY "Allow authenticated users to read all likes"
ON public.likes
FOR SELECT
TO authenticated -- Applies to the ‘authenticated’ role
USING (true);

-- INSERT Policy
-- Authenticated users can press “Like,” and user_id must be their own.
CREATE POLICY "Allow authenticated users to like posts"
ON public.likes
FOR INSERT
TO authenticated -- Roles that can attempt INSERT (authenticated users)
WITH CHECK (user_id = (SELECT auth.uid()));

-- DELETE Policy
-- Users can cancel (delete) the “Likes” they have pressed.
CREATE POLICY "Allow users to unlike posts (delete their own like)"
ON public.likes
FOR DELETE
TO authenticated -- Roles that can attempt DELETE (authenticated users)
USING (user_id = (SELECT auth.uid()));
```

### 5. post-images storage RLS
```sql
-- 1. SELECT Policy
CREATE POLICY "Allow authenticated users to list post images"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'post-images'
);

-- 2. INSERT Policy
CREATE POLICY "Allow admin to upload post images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'post-images' AND
  public.get_user_role(auth.uid()) = 'admin'
);

-- 3. UPDATE Policy
CREATE POLICY "Allow admin to update own post images"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'post-images' AND
  owner_id::uuid = (select auth.uid()) AND
  public.get_user_role(auth.uid()) = 'admin'
);

-- 4. DELETE Policy
CREATE POLICY "Allow admin to delete own post images"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'post-images' AND
  owner_id::uuid = (select auth.uid()) AND
  public.get_user_role(auth.uid()) = 'admin'
);
```

### 6. avatars storage RLS
```sql
-- public/userId/avatar/uuid.ext
-- 1. SELECT policy
CREATE POLICY "Allow authenticated users to list avatars"
ON storage.objects FOR SELECT
TO authenticated
USING ( bucket_id = 'avatars' );

-- 2. INSERT policy
CREATE POLICY "Allow users to upload their own avatar"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'avatars' AND
  auth.uid()::text = (storage.foldername(name))[2]
);

-- 3. UPDATE policy
CREATE POLICY "Allow users to update their own avatar"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'avatars' AND
  auth.uid()::text = (storage.foldername(name))[2]
);

-- 4. DELETE policy
CREATE POLICY "Allow users to delete their own avatar"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'avatars' AND
  auth.uid()::text = (storage.foldername(name))[2]
);
```

## Functions and Triggers
### 1. get_user_role
```sql
CREATE OR REPLACE FUNCTION public.get_user_role(p_user_id UUID)
RETURNS TEXT
LANGUAGE sql
STABLE -- STABLE because it only searches without changing data
SECURITY INVOKER -- Run with the caller's privileges (requires SELECT permission on the profiles table)
SET search_path TO public
AS $$
  SELECT role FROM public.profiles WHERE id = p_user_id;
$$;
```

### 2. is_admin
```sql
CREATE OR REPLACE FUNCTION public.is_admin(p_user_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY INVOKER
SET search_path TO public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = p_user_id AND role = 'admin'
  );
$$;
```

### 3. handle_new_user
```sql
-- Automatic profile creation function for new users
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO public
AS $$
BEGIN
  INSERT INTO public.profiles (id, username, role)
  VALUES (
    NEW.id,
    NEW.raw_user_meta_data->>'username',
    COALESCE(NEW.raw_user_meta_data->>'role', 'user')
  );
  RETURN NEW;
END;
$$;

-- Trigger to be executed after a user is added to the auth.users table
CREATE OR REPLACE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
```

### 4. trigger_set_timestamp
```sql
-- Trigger function that sets the updated_at column to the current time
CREATE OR REPLACE FUNCTION public.trigger_set_timestamp()
RETURNS TRIGGER 
LANGUAGE plpgsql
SET search_path TO public
AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

-- Applying the updated_at trigger to the profiles table
CREATE OR REPLACE TRIGGER set_profiles_updated_at
BEFORE UPDATE ON public.profiles
FOR EACH ROW
EXECUTE PROCEDURE public.trigger_set_timestamp();

-- Applying the updated_at trigger to the posts table
CREATE OR REPLACE TRIGGER set_posts_updated_at
BEFORE UPDATE ON public.posts
FOR EACH ROW
EXECUTE PROCEDURE public.trigger_set_timestamp();

-- Applying the updated_at trigger to the comments table
CREATE OR REPLACE TRIGGER set_comments_updated_at
BEFORE UPDATE ON public.comments
FOR EACH ROW
EXECUTE PROCEDURE public.trigger_set_timestamp();
```

### 5. update_comments_count
```sql
CREATE OR REPLACE FUNCTION public.update_comments_count()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER -- Need permission to modify posts table
SET search_path TO public
AS $$
BEGIN
  UPDATE public.posts
  SET comments_count = (
    SELECT COUNT(*)
    FROM public.comments
    WHERE post_id = COALESCE(NEW.post_id, OLD.post_id)
  )
  WHERE id = COALESCE(NEW.post_id, OLD.post_id);

  RETURN NULL;
END;
$$;

CREATE OR REPLACE TRIGGER on_comment_change_update_post_comments_count
  AFTER INSERT OR DELETE ON public.comments
  FOR EACH ROW EXECUTE PROCEDURE public.update_comments_count();
```

### 6. update_likes_count
```sql
CREATE OR REPLACE FUNCTION public.update_likes_count()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO public
AS $$
BEGIN
  -- Always update by recounting the actual count, rather than adding or subtracting.
  -- This ensures 100% data integrity.
  UPDATE public.posts
  SET likes_count = (
    SELECT COUNT(*)
    FROM public.likes
    WHERE post_id = COALESCE(NEW.post_id, OLD.post_id)
  )
  WHERE id = COALESCE(NEW.post_id, OLD.post_id);

  RETURN NULL; -- AFTER triggers return NULL because their return value is not important.
END;
$$;

-- COALESCE(NEW.post_id, OLD.post_id) is a smart way 
-- to use NEW.post_id for INSERTs and OLD.post_id for DELETEs.

CREATE OR REPLACE TRIGGER on_like_change_update_post_likes_count
  AFTER INSERT OR DELETE ON public.likes
  FOR EACH ROW EXECUTE PROCEDURE public.update_likes_count();
```

### 7. handle_like
```sql
CREATE OR REPLACE FUNCTION public.handle_like(p_post_id UUID)
RETURNS JSON
LANGUAGE plpgsql
SET search_path TO public
AS $$
DECLARE
  current_user_id UUID := auth.uid();
  like_exists BOOLEAN;
  final_likes_count INT;
BEGIN
  -- Check if the current user has already liked it
  SELECT EXISTS (
    SELECT 1 FROM public.likes
    WHERE post_id = p_post_id AND user_id = current_user_id
  ) INTO like_exists;

  IF like_exists THEN
    -- If you have already liked it, delete it (unlike it)
    DELETE FROM public.likes
    WHERE post_id = p_post_id AND user_id = current_user_id;
  ELSE
    -- If you haven't liked it, add it
    INSERT INTO public.likes (post_id, user_id)
    VALUES (p_post_id, current_user_id);
  END IF;

  -- ✨ IMPORTANT: After the trigger completes all calculations,
  -- the final values ​​to be returned to the client are read back from the posts table.
  SELECT likes_count INTO final_likes_count
  FROM public.posts
  WHERE id = p_post_id;

  RETURN json_build_object(
    'liked', NOT like_exists, -- New Like Status
    'likes_count', final_likes_count
  );
END;
$$;
```

### 8. update_user_profile
```sql
CREATE OR REPLACE FUNCTION public.update_user_profile(
  new_username TEXT,
  new_avatar_url TEXT
)
RETURNS SETOF public.profiles -- Returns a set of updated profile records
LANGUAGE plpgsql
-- SECURITY DEFINER: This function runs with the privileges of the owner 
-- who created the function (usually an administrator).
-- This privilege is required to modify the auth.users table.
SECURITY DEFINER
SET search_path TO public
AS $$
BEGIN
  -- 1. Update the public.profiles table
  -- Use auth.uid() in the WHERE clause 
  -- to restrict users to modifying only their own profile.
  UPDATE public.profiles
  SET
    username = new_username,
    avatar_url = new_avatar_url,
    updated_at = NOW() 
  WHERE id = auth.uid();

  -- 2. Update user_metadata in the auth.users table
  -- Use the jsonb || operator to overwrite existing metadata with new values
  UPDATE auth.users
  SET
    raw_user_meta_data = raw_user_meta_data || jsonb_build_object('username', new_username, 'avatar_url', new_avatar_url)
  WHERE id = auth.uid();

  -- 3. Returns the most recent updated profile information
  RETURN QUERY
  SELECT * FROM public.profiles WHERE id = auth.uid();
END;
$$;
```

### 9. get_my_posts
```sql
-- Function to get all posts by a specific author with pagination
CREATE OR REPLACE FUNCTION public.get_my_posts(p_author_id UUID, p_limit INT, p_offset INT)
RETURNS SETOF public.post_display_view
LANGUAGE plpgsql
SET search_path TO public
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.post_display_view
  WHERE author_id = p_author_id
  ORDER BY post_created_at DESC
  LIMIT p_limit
  OFFSET p_offset;
END;
$$;
```

### 10. search_posts
```sql
CREATE OR REPLACE FUNCTION public.search_posts(p_search_query TEXT)
RETURNS SETOF public.post_display_view
LANGUAGE plpgsql
SET search_path TO public
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.post_display_view
  WHERE
    -- PostgreSQL Full-Text Search 사용 (language: english)
    -- pg_catalog.english is the English text search configuration built into PostgreSQL.
    to_tsvector('pg_catalog.english', title || ' ' || content) @@ plainto_tsquery('pg_catalog.english', p_search_query)
  ORDER BY post_created_at DESC LIMIT 20;
END;
$$;
```

### 11. create_post_and_return_post_display_view
```sql
-- Create a new post and return the post display view
CREATE OR REPLACE FUNCTION public.create_post_and_return_post_display_view(
  p_post_id UUID,
  p_title TEXT,
  p_content TEXT,
  p_image_url TEXT
)
RETURNS SETOF public.post_display_view -- Use the post_display_view as the return type.
LANGUAGE plpgsql
SET search_path TO public
AS $$
DECLARE
  current_user_id UUID := auth.uid();
BEGIN
  -- Insert the new post
  INSERT INTO public.posts (id, author_id, title, content, image_url)
  VALUES (p_post_id, current_user_id, p_title, p_content, p_image_url);

  -- Return the newly created post from the view
  RETURN QUERY
  SELECT *
  FROM public.post_display_view
  WHERE post_id = p_post_id;
END;
$$;
```

### 12. update_post_and_return_post_display_view
```sql
-- Update a post and return the post display view
CREATE OR REPLACE FUNCTION public.update_post_and_return_post_display_view(
  p_post_id UUID,
  p_title TEXT,
  p_content TEXT,
  p_image_url TEXT
)
RETURNS SETOF public.post_display_view -- Use the post_display_view as the return type.
LANGUAGE plpgsql
SET search_path TO public
AS $$
BEGIN
  -- Update the posts table
  -- The RLS policy will ensure that the user can only update their own posts.
  UPDATE public.posts
  SET
    title = p_title,
    content = p_content,
    image_url = p_image_url
  WHERE id = p_post_id;

  -- Return the updated post from the view
  RETURN QUERY
  SELECT *
  FROM public.post_display_view
  WHERE post_id = p_post_id;
END;
$$;
```

### 13. create_comment_and_return_comment_display_view
```sql
-- Create a new comment and return the comment display view
CREATE OR REPLACE FUNCTION public.create_comment_and_return_comment_display_view(
  p_post_id UUID,
  p_content TEXT
)
RETURNS SETOF public.comment_display_view
LANGUAGE plpgsql
SET search_path TO public
AS $$
DECLARE
  new_comment_id UUID;
BEGIN
  -- Insert the new comment and get its ID
  INSERT INTO public.comments (post_id, user_id, content)
  VALUES (p_post_id, auth.uid(), p_content)
  RETURNING id INTO new_comment_id;

  -- The 'update_comments_count' trigger will automatically increment the comments_count.

  -- Return the newly created comment from the view
  RETURN QUERY
  SELECT *
  FROM public.comment_display_view
  WHERE id = new_comment_id;
END;
$$;
```

### 14. update_comment_and_return_comment_display_view
```sql
-- Update a comment and return the comment display view
CREATE OR REPLACE FUNCTION public.update_comment_and_return_comment_display_view(
  p_comment_id UUID,
  p_new_content TEXT
)
RETURNS SETOF public.comment_display_view -- Use the comment_display_view as the return type.
LANGUAGE plpgsql
SET search_path TO public
AS $$
BEGIN
  -- Update the comments table
  -- The RLS policy will ensure the user can only update their own comment.
  -- The trigger 'set_comments_updated_at' will automatically update the 'updated_at' field.
  UPDATE public.comments
  SET
    content = p_new_content
  WHERE id = p_comment_id;

  -- Return the updated comment from the view
  RETURN QUERY
  SELECT *
  FROM public.comment_display_view
  WHERE id = p_comment_id;
END;
$$;
```

## Views
### 1. post_display_view
```sql
-- Create a post_display_view view
CREATE OR REPLACE VIEW public.post_display_view 
with (security_invoker = on) AS
SELECT
  p.id AS post_id,
  p.title,
  p.content,
  p.image_url,
  p.created_at AS post_created_at,
  p.updated_at AS post_updated_at,
  p.author_id,
  u.username AS author_username,
  u.avatar_url AS author_avatar_url,
  u.role AS author_role,
  p.likes_count,
  p.comments_count,
  EXISTS(
    SELECT 1
    FROM public.likes l
    WHERE l.post_id = p.id AND l.user_id = auth.uid()
  ) AS current_user_liked
FROM
  public.posts p
JOIN
  public.profiles u ON p.author_id = u.id;
```

### 2. comment_display_view
```sql
CREATE OR REPLACE VIEW public.comment_display_view 
with (security_invoker = on) AS
SELECT
  c.id,
  c.post_id,
  c.content,
  c.created_at,
  c.user_id AS author_id,
  p.username AS author_username,
  p.avatar_url AS author_avatar_url
FROM
  public.comments c
  JOIN public.profiles p ON c.user_id = p.id
ORDER BY
  c.created_at DESC; -- Sort by most recent comments
```

## Indexes
### 1. index for full-text search
```sql
CREATE INDEX posts_fts_idx 
ON public.posts 
USING GIN (to_tsvector('pg_catalog.english', title || ' ' || content));
```

## Misc.
### 1. update role to admin
```sql
update public.profiles
set role='admin', updated_at=now()
where id = '9bc26f18-9e00-4dc8-ba72-49d01cda6389' returning *;

-- update auth.users
-- set raw_user_meta_data=raw_user_meta_data || jsonb_build_object('role', 'admin')
-- where id = '9bc26f18-9e00-4dc8-ba72-49d01cda6389' returning *;
```